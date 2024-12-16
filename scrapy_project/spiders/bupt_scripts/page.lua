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
    assert(wait_for_element(splash, '.name.getCompany', args.wait))
    assert(wait_for_element(splash, '.midInfo > .l_con', args.wait))
    local topic_text = splash:select('.name.getCompany'):text()
    local info_text = splash:select('.midInfo > .l_con'):text()
    return {
        topic_text = topic_text,
        info_text = info_text
    }
end
