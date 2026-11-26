<div id="login" class="container">

    <div class="pfa-login-header">
        <img class="pfa-login-logo mf-logo-pos" src="{$rel_path}images/brand/martdesign-positivo-horizontal.svg" alt="mARTdesign"/>
        <img class="pfa-login-logo mf-logo-neg" src="{$rel_path}images/brand/martdesign-negativo-horizontal.svg" alt="mARTdesign"/>
        <p class="pfa-login-eyebrow">{$PALANG.pLogin_eyebrow_generic}</p>
        <h1 class="pfa-login-title">{$PALANG.pPassword_change_heading}</h1>
    </div>

    <div class="well">
        <form name="mailbox" method="post" class="form">

            <div class="form-group">
                <label for="fUsername">{$PALANG.pLogin_username}:</label>
                <input class="form-control" type="email" name="fUsername" id="fUsername" value="{$tUsername}" autocomplete="username"/>
            </div>

            <div class="form-group">
                <label for="fCode">{$PALANG.pPassword_password_code}:</label>
                <input class="form-control" type="text" name="fCode" id="fCode" value="{$tCode}" autocomplete="one-time-code"/>
            </div>

            <div class="form-group">
                <label for="fPassword">{$PALANG.pPassword_password}:</label>
                <input class="form-control" type="password" name="fPassword" id="fPassword" autocomplete="new-password"/>
            </div>

            <div class="form-group">
                <label for="fPassword2">{$PALANG.pPassword_password2}:</label>
                <input class="form-control" type="password" name="fPassword2" id="fPassword2" autocomplete="new-password"/>
            </div>

            {if $tTotpRequired}
            <div class="form-group">
                <label for="fTOTP_code">{$PALANG.pTOTP_confirm}:</label>
                <input id="fTOTP_code" class="form-control" type="text" name="fTOTP_code"
                       inputmode="numeric" autocomplete="one-time-code" />
            </div>
            {/if}

            <div class="text-center">
                <button class="btn btn-primary btn-lg" type="submit" name="submit" value="submit">{$PALANG.pPassword_change_heading}</button>
            </div>
        </form>
        <div class="pfa-login-alt">
            <a href="login.php">← {$PALANG.pPassword_back_to_login}</a>
        </div>
    </div>
</div>
