<div id="login" class="container">

    <div class="pfa-login-header">
        <img class="pfa-login-logo mf-logo-pos" src="{$rel_path}images/brand/martdesign-positivo-horizontal.svg" alt="mARTdesign"/>
        <img class="pfa-login-logo mf-logo-neg" src="{$rel_path}images/brand/martdesign-negativo-horizontal.svg" alt="mARTdesign"/>
        <p class="pfa-login-eyebrow">{$PALANG.pLogin_eyebrow_generic}</p>
        <h1 class="pfa-login-title">{$PALANG.pPassword_recovery_heading}</h1>
        <p class="pfa-login-lead">{$PALANG.pPassword_recovery_title}</p>
    </div>

    <div class="well">
        <form name="frmPassword" method="post" action="" class="form">
            <div class="form-group">
                <label for="fUsername">{$PALANG.pLogin_username}:</label>
                <input class="form-control" type="email" name="fUsername" id="fUsername" autocomplete="username"/>
            </div>
            <div class="text-center">
                <button type="submit" class="btn btn-primary btn-lg" name="submit" value="submit">{$PALANG.pPassword_recovery_button}</button>
            </div>
        </form>
        <div class="pfa-login-alt">
            <a href="login.php">← {$PALANG.pPassword_back_to_login}</a>
        </div>
    </div>

    <script type="text/javascript">
        document.frmPassword.fUsername.focus();
    </script>
</div>
