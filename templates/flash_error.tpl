<!-- {$smarty.template} -->
{strip}
    {if isset($smarty.session.flash) && (isset($smarty.session.flash.info) || isset($smarty.session.flash.error))}
        <div class="mf-flash-stack{if isset($mf_auth_page) && $mf_auth_page} mf-flash-stack--footer{/if}">
            {if isset($smarty.session.flash.info)}
                <div class="mf-flash mf-flash-success" role="status" data-mf-flash="auto">
                    <ul class="flash-info">
                        {foreach from=$smarty.session.flash.info item=msg}
                            <li>{$msg|escape:html}</li>
                        {/foreach}
                    </ul>
                </div>
            {/if}
            {if isset($smarty.session.flash.error)}
                <div class="mf-flash mf-flash-error" role="alert" data-mf-flash="manual">
                    <ul class="flash-error">
                        {foreach from=$smarty.session.flash.error item=msg}
                            <li>{$msg|escape:html}</li>
                        {/foreach}
                    </ul>
                </div>
            {/if}
        </div>
    {/if}
{/strip}
<script type="text/javascript">
{literal}
(function () {
    // Every notice bar gets a close button. Success ("auto") notices leave by themselves
    // after 5 s, a bit more for long texts (reading time); the timer pauses while the
    // pointer or the keyboard focus is on the notice. Errors ("manual") stay until closed.
    // Inside the app the notices float under the title bar; on the login pages they
    // sit on the footer (sticky). Neither moves the page when a notice leaves.
    var CLOSE_LABEL = {/literal}"{$PALANG.pFlash_close|escape:'javascript'}"{literal};
    var MIN_DELAY = 5000;

    function readingDelay(bar) {
        var words = (bar.textContent || '').trim().split(/\s+/).length;
        return Math.max(MIN_DELAY, 1500 + words * 250);
    }

    function fitFooterStack(stack) {
        if (!stack || !stack.classList.contains('mf-flash-stack--footer')) { return; }
        // Takes no room in the layout: sits over the bottom padding of the page
        stack.style.marginTop = (-stack.offsetHeight) + 'px';
    }

    function dismiss(bar, byKeyboard) {
        if (bar.getAttribute('data-mf-leaving')) { return; }
        bar.setAttribute('data-mf-leaving', '1');
        bar.classList.add('mf-flash--leaving');
        window.setTimeout(function () {
            var stack = bar.parentNode;
            if (stack) { stack.removeChild(bar); }
            if (stack && stack.classList && stack.classList.contains('mf-flash-stack')) {
                if (!stack.querySelector('[data-mf-flash]')) {
                    stack.parentNode.removeChild(stack);
                } else {
                    fitFooterStack(stack);
                }
            }
            if (byKeyboard) {
                // The close button is gone: give the focus back to the page content
                var main = document.querySelector('main');
                if (main) {
                    main.setAttribute('tabindex', '-1');
                    main.focus({ preventScroll: true });
                }
            }
        }, 220);
    }

    function setup(bar) {
        if (bar.getAttribute('data-mf-ready')) { return; }
        bar.setAttribute('data-mf-ready', '1');
        bar.classList.add('mf-flash');

        var btn = document.createElement('button');
        btn.type = 'button';
        btn.className = 'mf-flash-close';
        btn.setAttribute('aria-label', CLOSE_LABEL);
        btn.setAttribute('title', CLOSE_LABEL);
        btn.innerHTML = '<svg viewBox="0 0 24 24" aria-hidden="true" focusable="false"><line x1="6" y1="6" x2="18" y2="18"/><line x1="18" y1="6" x2="6" y2="18"/></svg>';
        btn.addEventListener('click', function () {
            dismiss(bar, document.activeElement === btn);
        });
        bar.appendChild(btn);

        if (bar.getAttribute('data-mf-flash') !== 'auto') { return; }
        var timer = null;
        var delay = readingDelay(bar);
        function start() { stop(); timer = window.setTimeout(function () { dismiss(bar, false); }, delay); }
        function stop() { if (timer) { window.clearTimeout(timer); timer = null; } }
        bar.addEventListener('mouseenter', stop);
        bar.addEventListener('mouseleave', start);
        bar.addEventListener('focusin', stop);
        bar.addEventListener('focusout', start);
        start();
    }

    function init() {
        var bars = document.querySelectorAll('[data-mf-flash]');
        for (var i = 0; i < bars.length; i++) { setup(bars[i]); }
        var stacks = document.querySelectorAll('.mf-flash-stack--footer');
        for (var j = 0; j < stacks.length; j++) { fitFooterStack(stacks[j]); }
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
    window.addEventListener('resize', function () {
        var stacks = document.querySelectorAll('.mf-flash-stack--footer');
        for (var j = 0; j < stacks.length; j++) { fitFooterStack(stacks[j]); }
    });
})();
{/literal}
</script>
