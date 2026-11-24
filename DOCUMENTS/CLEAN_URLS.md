# Clean URLs (Front Controller Routing)

PostfixAdmin includes an optional front controller (`public/router.php` + `model/Router.php`) that replaces direct `*.php` URLs with clean extensionless routes and allows your web server to block external direct access to PHP files.

## Enabling Clean URLs

1. Add the following to `config.local.php`:

```php
$CONF['clean_urls'] = 'YES';
// Optional: if hosted under a subdirectory like https://example.com/postfixadmin
// $CONF['base_url_path'] = '/postfixadmin';
```

2. Configure your web server using one of the examples below.

---

## Route Mapping

### Admin Routes
| Clean URL | Target Script |
| :--- | :--- |
| `/login`, `/login-mfa`, `/main` | `login.php`, `login-mfa.php`, `main.php` |
| `/list/{table}` *(e.g. `/list/domain`, `/list/admin`, `/list/fetchmail`, `/list/dkim`)* | `list.php?table={table}` |
| `/edit/{table}` *(e.g. `/edit/domain`, `/edit/mailbox`, `/edit/alias`, `/edit/admin`)* | `edit.php?table={table}` |
| `/editactive/{table}`, `/delete/{table}` | `editactive.php?table={table}`, `delete.php?table={table}` |
| `/virtual` | `list-virtual.php` |
| `/sendmail`, `/broadcast` | `sendmail.php`, `broadcast-message.php` |
| `/viewlog`, `/backup`, `/vacation` | `viewlog.php`, `backup.php`, `vacation.php` |
| `/totp`, `/totp-exceptions`, `/app-passwords` | `totp.php`, `totp-exceptions.php`, `app-passwords.php` |
| `/password-recover`, `/password-change` | `password-recover.php`, `password-change.php` |
| `/setup`, `/xmlrpc` | `setup.php`, `xmlrpc.php` |

> **Security note:** `upgrade.php` is intentionally NOT exposed as a public route — database schema upgrades should be run authenticated via `/setup` (or CLI). In production, restrict `/setup` by IP (or return `404`) once installation/upgrade is complete.

### End-User Routes (`/users/*`)
| Clean URL | Target Script |
| :--- | :--- |
| `/users`, `/users/login`, `/users/login-mfa`, `/users/main` | `users/index.php`, `users/login.php`, `users/login-mfa.php`, `users/main.php` |
| `/users/password`, `/users/edit-alias`, `/users/vacation` | `users/password.php`, `users/edit-alias.php`, `users/vacation.php` |
| `/users/totp`, `/users/totp-exceptions`, `/users/app-passwords` | `users/totp.php`, `users/totp-exceptions.php`, `users/app-passwords.php` |
| `/users/password-recover`, `/users/password-change` | `users/password-recover.php`, `users/password-change.php` |

---

## Nginx Configuration (Recommended — Blocks Direct `*.php` Access)

```nginx
server {
    listen 443 ssl;
    server_name mailadmin.example.com;
    root /var/www/postfixadmin/public;

    # Optional: restrict /setup to administrator IP or disable after initial setup
    location = /setup {
        # allow 203.0.113.10;
        # deny all;
        try_files /nonexistent /router.php$is_args$args;
    }

    # Rate-limit authentication and password recovery endpoints (adjust zone name to match nginx.conf)
    location ~ ^/(?:users/)?(?:login|login-mfa|password-recover|password-change)$ {
        limit_req zone=login burst=5 nodelay;
        try_files /nonexistent /router.php$is_args$args;
    }

    # Serve static files directly; route everything else through router.php
    location / {
        try_files $uri /router.php$is_args$args;
    }

    # Only allow internal dispatch to the front controller
    location = /router.php {
        internal;
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/mailadmin.sock;
    }

    # Block direct external requests to any *.php file (e.g. /edit.php, /setup.php, /upgrade.php)
    location ~ \.php$ {
        return 404;
    }
}
```

## Apache Configuration (`.htaccess` inside `public/`)

```apache
<IfModule mod_rewrite.c>
    RewriteEngine On

    # Block direct external requests to *.php files (except internal rewrites to router.php)
    RewriteCond %{THE_REQUEST} \s/+[^\s]*\.php[\s?] [NC]
    RewriteRule ^ - [R=404,L]

    # Route all non-file requests to router.php
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^ router.php [L,QSA]
</IfModule>
```
