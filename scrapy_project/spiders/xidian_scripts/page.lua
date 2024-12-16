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
    assert(wait_for_element(splash, '.details-title.clearfix', args.wait))
    local ad_topic = splash:select('.title-message > h5'):text()
    local share_info = splash:select_all('.share > ul > li')
    local post_date_string = share_info[1]:text()
    local visit_count_string = share_info[2]:text()

    return {
        ad_topic = ad_topic,
        post_date_string = post_date_string,
        visit_count_string = visit_count_string
    }
end
