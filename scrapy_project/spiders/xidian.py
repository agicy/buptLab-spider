import scrapy
from scrapy_splash import SplashRequest
from scrapy_project.settings import min_date, read_file
from scrapy_project.items import JobAdItem
from datetime import datetime
from pathlib import Path

WAIT_TIME = 5


class XidianSpider(scrapy.Spider):
    name = "xidian"

    def start_requests(self):
        yield SplashRequest(
            url="https://job.xidian.edu.cn/campus/index/do1/job.xidian.edu.cn/domain/xidian/city//page/",
            endpoint="execute",
            args={
                "lua_source": read_file(
                    str(
                        Path(__file__).resolve().parent
                        / "xidian_scripts"
                        / "number.lua"
                    )
                ),
                "wait": WAIT_TIME,
            },
            callback=self.parse_list,
        )

    def parse_list(self, response):
        total_page = int(response.data["total_page"])
        self.logger.info(f"Found {total_page} pages")

        for i in range(1, total_page + 1):
            url = f"https://job.xidian.edu.cn/campus/index/do1/job.xidian.edu.cn/domain/xidian/city//page/{i}"
            self.logger.info(f"Scraping page {i}/{total_page}... {url}")
            yield SplashRequest(
                url=url,
                endpoint="execute",
                args={
                    "lua_source": read_file(
                        str(
                            Path(__file__).resolve().parent
                            / "xidian_scripts"
                            / "list.lua"
                        )
                    ),
                    "wait": WAIT_TIME,
                },
                callback=self.parse_list_page,
            )

    total_valid_count = 0
    total_ad = 0

    def parse_list_page(self, response):
        items = response.data["items"]

        self.logger.info(f"Found {len(items)} items on page {response.url}")

        valid_urls = []
        invalid_count = 0

        for item in items.values():
            relative_url = item["relative_url"]
            post_date_string = item["date_string"]

            post_date = datetime.strptime(post_date_string, r"%Y-%m-%d %H:%M:%S").date()

            if post_date >= min_date:
                absolute_url = response.urljoin(relative_url)
                valid_urls.append(absolute_url)
            else:
                invalid_count += 1

        self.logger.info(
            f"Found {len(valid_urls)} valid urls, {invalid_count} invalid urls, Total: {len(valid_urls) + invalid_count} on page {response.url}"
        )

        self.total_valid_count += len(valid_urls)

        for url in valid_urls:
            self.total_ad += 1
            self.logger.info(
                f"Processing advertisement {self.total_ad}/{self.total_valid_count}... {url}"
            )
            yield SplashRequest(
                url=url,
                endpoint="execute",
                args={
                    "lua_source": read_file(
                        str(
                            Path(__file__).resolve().parent
                            / "xidian_scripts"
                            / "page.lua"
                        )
                    ),
                    "wait": WAIT_TIME,
                },
                callback=self.parse_item,
            )

    def parse_item(self, response):
        ad_topic = response.data["ad_topic"]
        post_date_string = response.data["post_date_string"]
        visit_count_string = response.data["visit_count_string"]

        post_date = datetime.strptime(
            post_date_string.split("发布时间：")[1].strip(),
            r"%Y-%m-%d %H:%M",
        ).date()
        visit_count = int(visit_count_string.split("浏览次数：")[1].strip())

        item = JobAdItem()
        item["ad_topic"] = ad_topic
        item["post_date"] = post_date
        item["visit_count"] = visit_count
        yield item
