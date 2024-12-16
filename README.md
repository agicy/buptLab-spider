# buptLab-spider

这个仓库包含了北京邮电大学 2024-2025 秋季学期《Python 程序设计》课程期末大作业的相关代码和报告。

## 使用说明

### 环境配置

#### 安装 Python 依赖

进入项目根目录，执行命令
```sh
pip install -r requirements.txt
```

#### 配置 Splash

执行命令
```sh
docker pull scrapinghub/splash
```

### 运行

#### 启动 Splash

启动爬虫前需要启动 Splash 服务，执行命令
```sh
docker run `
-p 8050:8050 `
scrapinghub/splash `
--disable-lua-sandbox
```

#### 运行爬虫并处理数据

执行命令
```sh
python main.py
```
以启动爬虫，爬取完成后将自动进行数据处理。

## 目录结构

```
.
├── data                          # 数据
│   ├── bupt.csv                  # BuptSpider 爬取的数据
│   ├── xidian.csv                # XidianSpider 爬取的数据
│   └── 就业信息汇总.xlsx          # 处理和整合的结果
├── main.py                       # 主程序
├── requirements.txt              # 依赖文件，内含所需的 Python 包及其版本
├── scrapy.cfg                    # Scrapy 框架的配置文件
└── scrapy_project                # Scrapy 爬虫项目文件夹
    ├── __init__.py
    ├── items.py                  # 定义爬虫抓取的数据结构 JobAdItem
    ├── middlewares.py            # 定义爬虫中间件，用于处理请求和响应
    ├── pipelines.py              # 定义数据管道，用于处理和存储抓取到的数据
    ├── settings.py               # 配置文件
    └── spiders                   # 爬虫文件夹
        ├── __init__.py
        ├── bupt.py               # 内含 BuptSpider
        ├── bupt_scripts          # bupt 所用 Lua 脚本
        │   └── <script_name>.lua
        ├── xidian.py             # 内含 XidianSpider
        └── xidian_scripts        # xidian 所用 Lua 脚本
            └── <script_name>.lua
```
