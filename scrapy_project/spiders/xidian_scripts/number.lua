function wait_for_element(splash, css, maxwait)
    assert(splash)
    assert(css)
    assert(maxwait)
    return splash:wait_for_resume(string.format([[
        function main(splash) {
            var selector = '%s';
            var maxwait = %s;
            var end = Date.now() + maxwait * 1000;

            function check() {
                if(document.querySelector(selector)) {
                    splash.resume('Element found');
                } else if(Date.now() >= end) {
                    var err = 'Timeout waiting for element';
                    splash.error(err + " " + selector);
                } else {
                    setTimeout(check, 200);
                }
            }
            check();
        }
    ]], css, maxwait))
end

function is_date_valid(date, min_date)
    local function to_timestamp(date_str)
        local year, month, day = date_str:match("(%d+)-(%d+)-(%d+)")
        return os.time({
            year = year,
            month = month,
            day = day
        })
    end

    local timestamp = to_timestamp(date)
    local min_timestamp = to_timestamp(min_date)

    return timestamp >= min_timestamp
end

function main(splash, args)
    assert(splash:go(string.format("%s%d", args.url, 1)))
    assert(wait_for_element(splash, '.pages', args.wait))
    local links = splash:select('.pages'):querySelectorAll('a')
    local total_page = links[#links - 1]:text()

    local l = 1
    local r = tonumber(total_page)

    while l < r do
        local mid = math.floor((l + r) / 2)
        local page_mid_url = string.format("%s%d", args.url, mid)

        assert(splash:go(page_mid_url))
        assert(wait_for_element(splash, '.infoList', args.wait))
        local item_elements = splash:select_all('.infoList')

        local first_date_string = item_elements[1]:querySelector('.span4'):text()
        local last_date_string = item_elements[#item_elements]:querySelector('.span4'):text()

        local valid_count = 0

        if is_date_valid(first_date_string, "2024-09-01") then
            valid_count = valid_count + 1
        end

        if is_date_valid(last_date_string, "2024-09-01") then
            valid_count = valid_count + 1
        end

        if valid_count == 2 then
            l = mid + 1
        else
            r = mid
        end
    end

    total_page = l

    return {
        total_page = total_page
    }
end
