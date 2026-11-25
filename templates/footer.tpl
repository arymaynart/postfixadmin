<!-- {$smarty.template} -->
<footer class="footer">
    <div class="pfa-footer-inner">
        <span class="pfa-footer-brand">
            <img class="mf-logo-pos" src="{$rel_path}images/brand/martdesign-positivo-horizontal.svg" alt="mARTdesign"/>
            <img class="mf-logo-neg" src="{$rel_path}images/brand/martdesign-negativo-horizontal.svg" alt="mARTdesign"/>
        </span>
        <div class="pfa-footer-meta">
            {if isset($smarty.session.sessid.username) && $smarty.session.sessid.username}
                <span>{$PALANG.pFooter_logged_as|replace:"%s":$smarty.session.sessid.username}</span>
            {else}
                <span>Serviço de E-mail</span>
            {/if}
            {if $CONF.show_footer_text == 'YES' && $CONF.footer_link}
                <span class="pfa-footer-sep">·</span>
                <a href="{$CONF.footer_link}" target="_blank" rel="noopener">{$CONF.footer_text} →</a>
            {/if}
        </div>
    </div>
</footer>
</body>
</html>
