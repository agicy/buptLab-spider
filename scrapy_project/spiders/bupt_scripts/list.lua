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

function wait_for_element_display_none(splash, css, maxwait)
    assert(splash)
    assert(css)
    assert(maxwait)
    return splash:wait_for_resume(string.format([[
        function main(splash) {
            var selector = '%s';
            var maxwait = %s;
            var end = Date.now() + maxwait * 1000;
            function check() {
                var elements = document.querySelectorAll(selector);
                var allAreNone = Array.from(elements).every(function(element) {
                    return window.getComputedStyle(element).display === 'none';
                });
                if (allAreNone) {
                    splash.resume('All elements found with display:none');
                } else if (Date.now() >= end) {
                    var err = 'Timeout waiting for all elements to be display:none';
                    splash.error(err + " " + selector);
                } else {
                    setTimeout(check, 200);
                }
            }
            check();
        }
    ]], css, maxwait))
end

function main(splash, args)
    assert(splash:go(args.url))

    assert(wait_for_element(splash, '.dataNum', args.wait))
    local data_num = tonumber(splash:select('.dataNum span'):text())

    splash:evaljs(string.format('page(1, %d)', data_num))
    assert(wait_for_element_display_none(splash, '.comp_loading', args.wait))

    local items = {}
    local item_elements = splash:select_all('.infoItem')
    for _, item_element in ipairs(item_elements) do
        assert(item_element)
        local relative_url = item_element:querySelector('a.tit'):getAttribute('href')
        local date_string = item_element:querySelector('.time'):text()
        table.insert(items, {
            relative_url = relative_url,
            date_string = date_string
        })
    end

    return {
        items = items
    }
end
