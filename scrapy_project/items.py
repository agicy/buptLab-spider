import scrapy

class JobAdItem(scrapy.Item):
    ad_topic = scrapy.Field()
    post_date = scrapy.Field()
    visit_count = scrapy.Field()
