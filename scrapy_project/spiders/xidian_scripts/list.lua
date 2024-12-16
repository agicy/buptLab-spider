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

function main(splash, args)
    assert(splash:go(args.url))
    assert(wait_for_element(splash, '.infoList', args.wait))
    local item_elements = splash:select_all('.infoList')

    local items = {}
    for i, item in pairs(item_elements) do
        local relative_url = item:querySelector('a'):getAttribute('href')
        local date_string = item:querySelector('.span4'):text()
        table.insert(items, {
            relative_url = relative_url,
            date_string = date_string
        })
    end

    return {
        items = items
    }
end
