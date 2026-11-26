<div id="login" class="container">

    <div class="pfa-login-header">
        <img class="pfa-login-logo mf-logo-pos" src="{$rel_path}images/brand/martdesign-positivo-horizontal.svg" alt="mARTdesign"/>
        <img class="pfa-login-logo mf-logo-neg" src="{$rel_path}images/brand/martdesign-negativo-horizontal.svg" alt="mARTdesign"/>
        <p class="pfa-login-eyebrow">{if $logintype=='admin'}{$PALANG.pLogin_eyebrow_admin}{else}{$PALANG.pLogin_eyebrow_user}{/if}</p>
        <h1 class="pfa-login-title">{$PALANG.pLogin_title}</h1>
    </div>

    <div class="well">

        <form name="frmLogin" method="post" action="" role="form" class="form-signin">
            <input type="hidden" name="token" value="{$smarty.session.PFA_token|escape:"url"}"/>
            <div class="form-group">
                <label for="fUsername">{$PALANG.pLogin_username}:</label>
                <input class="form-control" type="text" name="fUsername" id="fUsername" autocomplete="username"/>
            </div>
            <div class="form-group">
                <label for="fPassword">{$PALANG.password}:</label>
                <input class="form-control" type="password" name="fPassword" id="fPassword" autocomplete="current-password"/>
            </div>
            <div class="form-group">
                <label for=lang>{$PALANG.pLogin_language}:</label>
                {$language_selector}
            </div>
            <div class="text-center">
                <button class="btn btn-primary btn-lg" type="submit" name="submit" value="{$PALANG.pLogin_button}"><span class="glyphicon glyphicon-log-in"
                                                    		aria-hidden="true"></span> {$PALANG.pLogin_button}</button>
            </div>
            {if $forgotten_password_reset}
                <div class="pfa-login-forgot">
                    <a href="password-recover.php">{$PALANG.pUsersLogin_password_recover}</a>
                </div>
            {/if}
        </form>
        {if $logintype == 'admin'}
            <div class="pfa-login-alt">
                <a href="users/">{$PALANG.pLogin_login_users} →</a>
            </div>
        {/if}
    </div>
    <script type="text/javascript">
        document.frmLogin.fUsername.focus();
    </script>
</div>
