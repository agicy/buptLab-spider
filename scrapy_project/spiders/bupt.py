import scrapy
from scrapy_splash import SplashRequest
from scrapy_project.settings import min_date, read_file
from scrapy_project.items import JobAdItem
from datetime import date, datetime
from pathlib import Path

WAIT_TIME = 5


class BuptSpider(scrapy.Spider):
    name = "bupt"

    def start_requests(self):
        yield SplashRequest(
            url="https://job.bupt.edu.cn/frontpage/bupt/html/recruitmentinfoList.html?type=1&",
            endpoint="execute",
            args={
                "lua_source": read_file(
                    str(Path(__file__).resolve().parent / "bupt_scripts" / "list.lua")
                ),
                "wait": WAIT_TIME,
            },
            callback=self.parse_list_page,
        )

    def parse_list_page(self, response):
        items: dict = response.data["items"]
        self.logger.info(f"Found {len(items)} items")

        valid_urls: list[str] = []
        invalid_url_count: int = 0
        for item in items.values():
            relative_url: str = item["relative_url"]
            date_string: str = item["date_string"]

            date = datetime.strptime(date_string, r"%Y-%m-%d").date()

            if date >= min_date:
                absolute_url = response.urljoin(relative_url)
                valid_urls.append(absolute_url)
            else:
                invalid_url_count += 1

        self.logger.info(
            f"Found {len(valid_urls)} valid urls, {invalid_url_count} invalid urls, total urls: {len(valid_urls) + invalid_url_count}."
        )

        for ith, url in enumerate(valid_urls, start=1):
            self.logger.info(
                f"Processing advertisement {ith}/{len(valid_urls)}... {url}"
            )
            yield SplashRequest(
                url=url,
                endpoint="execute",
                args={
                    "lua_source": read_file(
                        str(
                            Path(__file__).resolve().parent
                            / "bupt_scripts"
                            / "page.lua"
                        )
                    ),
                    "wait": WAIT_TIME,
                },
                callback=self.parse_item,
            )

    def parse_item(self, response):

        def get_ad_info(text: str) -> tuple[date, int]:
            date_string = text.split("日期：")[1].split()[0].strip()
            date = datetime.strptime(date_string, r"%Y-%m-%d").date()
            visit_count_string = text.split("浏览次数：")[1].split()[0].strip()
            visit_count = int(visit_count_string)
            return date, visit_count

        topic_text = response.data["topic_text"].strip()
        info_text = response.data["info_text"].strip()

        item = JobAdItem()
        item["ad_topic"] = topic_text
        item["post_date"], item["visit_count"] = get_ad_info(info_text)
        yield item
