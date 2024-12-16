import csv
import os
import scrapy
from scrapy_project.items import JobAdItem


class CsvPipeline:
    def open_spider(self, spider: scrapy.Spider):
        os.makedirs("data", exist_ok=True)
        self.file = open(f"data/{spider.name}.csv", "w", newline="")
        self.writer = csv.writer(self.file)
        self.writer.writerow(["ad_topic", "post_date", "visit_count"])

    def close_spider(self, _):
        self.file.close()

    def process_item(self, item: JobAdItem, _):
        self.writer.writerow([item["ad_topic"], item["post_date"], item["visit_count"]])
        return item
