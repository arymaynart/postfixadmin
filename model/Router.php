<?php

/**
 * Clean URL Router / Front Controller for PostfixAdmin.
 *
 * Activated opt-in via $CONF['clean_urls'] = 'YES' and public/router.php.
 * Keeps 100% backwards compatibility when disabled ($CONF['clean_urls'] = 'NO').
 */
class Router
{
    /** @var array<string, string> Static admin routes: clean path => script under public/ */
    private const ADMIN_ROUTES = [
        '/'                => 'index.php',
        '/login'           => 'login.php',
        '/login-mfa'       => 'login-mfa.php',
        '/main'            => 'main.php',
        '/virtual'         => 'list-virtual.php',
        '/sendmail'        => 'sendmail.php',
        '/broadcast'       => 'broadcast-message.php',
        '/viewlog'         => 'viewlog.php',
        '/backup'          => 'backup.php',
        '/vacation'        => 'vacation.php',
        '/totp'            => 'totp.php',
        '/totp-exceptions' => 'totp-exceptions.php',
        '/app-passwords'   => 'app-passwords.php',
        '/password-recover' => 'password-recover.php',
        '/password-change' => 'password-change.php',
        '/setup'           => 'setup.php',
        '/xmlrpc'          => 'xmlrpc.php',
        '/delete'          => 'delete.php',
        '/editactive'      => 'editactive.php',
    ];

    /** @var array<string, string> Static user routes: clean path => script under public/users/ */
    private const USER_ROUTES = [
        '/users'                  => 'index.php',
        '/users/login'            => 'login.php',
        '/users/login-mfa'        => 'login-mfa.php',
        '/users/main'             => 'main.php',
        '/users/password'         => 'password.php',
        '/users/edit-alias'       => 'edit-alias.php',
        '/users/vacation'         => 'vacation.php',
        '/users/totp'             => 'totp.php',
        '/users/totp-exceptions'  => 'totp-exceptions.php',
        '/users/app-passwords'    => 'app-passwords.php',
        '/users/password-recover' => 'password-recover.php',
        '/users/password-change'  => 'password-change.php',
    ];

    /** @var array<string, string> Reverse map for admin script => clean path */
    private const ADMIN_SCRIPT_TO_ROUTE = [
        'index.php'             => '/',
        'login.php'             => '/login',
        'login-mfa.php'         => '/login-mfa',
        'main.php'              => '/main',
        'list-virtual.php'      => '/virtual',
        'sendmail.php'          => '/sendmail',
        'broadcast-message.php' => '/broadcast',
        'viewlog.php'           => '/viewlog',
        'backup.php'            => '/backup',
        'vacation.php'          => '/vacation',
        'totp.php'              => '/totp',
        'totp-exceptions.php'   => '/totp-exceptions',
        'app-passwords.php'     => '/app-passwords',
        'password-recover.php'  => '/password-recover',
        'password-change.php'   => '/password-change',
        'setup.php'             => '/setup',
        'xmlrpc.php'            => '/xmlrpc',
        'delete.php'            => '/delete',
        'editactive.php'        => '/editactive',
        'list.php'              => '/list',
        'edit.php'              => '/edit',
    ];

    /** @var array<string, string> Reverse map for user script => clean path */
    private const USER_SCRIPT_TO_ROUTE = [
        'index.php'            => '/users',
        'login.php'            => '/users/login',
        'login-mfa.php'        => '/users/login-mfa',
        'main.php'             => '/users/main',
        'password.php'         => '/users/password',
        'edit-alias.php'       => '/users/edit-alias',
        'vacation.php'         => '/users/vacation',
        'totp.php'             => '/users/totp',
        'totp-exceptions.php'  => '/users/totp-exceptions',
        'app-passwords.php'    => '/users/app-passwords',
        'password-recover.php' => '/users/password-recover',
        'password-change.php'  => '/users/password-change',
    ];

    private static bool $currentUserContext = false;
    private static string $currentBasePath = '';

    /**
     * Normalize optional base path (e.g. '' or '/postfixadmin').
     */
    public static function normalizeBasePath(string $basePath): string
    {
        $basePath = trim($basePath);
        if ($basePath === '' || $basePath === '/') {
            return '';
        }
        return '/' . trim($basePath, '/');
    }

    /**
     * Safely extract an uncommented $CONF['base_url_path'] assignment from a PHP config snippet.
     */
    public static function extractBaseUrlPathFromSnippet(string $snippet): string
    {
        if (preg_match('/^\s*\$CONF\s*\[\s*[\'"]base_url_path[\'"]\s*\]\s*=\s*[\'"]([^\'"]*)[\'"]\s*;/m', $snippet, $m)) {
            return self::normalizeBasePath($m[1]);
        }
        return '';
    }

    /**
     * Resolve an incoming clean URL path to a target script and route parameters.
     *
     * @return array{script: string, user_context: bool, params: array<string, string>}|null
     */
    public static function resolve(string $requestPath, string $basePath = ''): ?array
    {
        if (strpos($requestPath, "\0") !== false || strpos($requestPath, '..') !== false) {
            return null;
        }

        $base = self::normalizeBasePath($basePath);
        $path = $requestPath;

        if ($base !== '') {
            if ($path === $base) {
                $path = '/';
            } elseif (strpos($path, $base . '/') === 0) {
                $path = substr($path, strlen($base));
            } else {
                return null;
            }
        }

        $path = '/' . ltrim($path, '/');
        if ($path !== '/') {
            $path = rtrim($path, '/');
        }

        // Exact user routes
        if (isset(self::USER_ROUTES[$path])) {
            return [
                'script'       => self::USER_ROUTES[$path],
                'user_context' => true,
                'params'       => [],
            ];
        }

        // Exact admin routes
        if (isset(self::ADMIN_ROUTES[$path])) {
            return [
                'script'       => self::ADMIN_ROUTES[$path],
                'user_context' => false,
                'params'       => [],
            ];
        }

        // Parameterized admin routes: /list/{table}, /edit/{table}, /editactive/{table}, /delete/{table}
        if (preg_match('#^/(list|edit|editactive|delete)/([a-z]+)$#', $path, $m)) {
            return [
                'script'       => $m[1] . '.php',
                'user_context' => false,
                'params'       => ['table' => $m[2]],
            ];
        }

        return null;
    }

    /**
     * Convert a legacy PostfixAdmin URL (e.g. "edit.php?table=mailbox&domain=example.com")
     * into its clean URL equivalent (e.g. "/edit/mailbox?domain=example.com").
     */
    public static function url(string $legacyUrl, bool $userContext = false, string $basePath = ''): string
    {
        $trimmed = trim($legacyUrl);
        if (
            $trimmed === ''
            || $trimmed[0] === '#'
            || strpos($trimmed, '//') === 0
            || preg_match('/[\r\n]/', $trimmed)
            || preg_match('#^(?:https?:|mailto:|javascript:|data:)#i', $trimmed)
        ) {
            return $legacyUrl;
        }

        $base = self::normalizeBasePath($basePath);

        // Split fragment
        $fragment = '';
        $hashPos = strpos($trimmed, '#');
        if ($hashPos !== false) {
            $fragment = substr($trimmed, $hashPos);
            $trimmed = substr($trimmed, 0, $hashPos);
        }

        // Split query string (handle HTML-encoded &amp; safely when called from templates)
        $queryStr = '';
        $qPos = strpos($trimmed, '?');
        if ($qPos !== false) {
            $queryStr = substr($trimmed, $qPos + 1);
            $trimmed = substr($trimmed, 0, $qPos);
        }

        // Handle relative prefix like "../login.php" or "users/login.php"
        $targetUserContext = $userContext;
        $cleanScript = ltrim($trimmed, '/');

        if (strpos($cleanScript, '../') === 0) {
            $cleanScript = substr($cleanScript, 3);
            $targetUserContext = false;
        } elseif (strpos($cleanScript, 'users/') === 0) {
            $cleanScript = substr($cleanScript, 6);
            $targetUserContext = true;
        }

        // Only rewrite known PostfixAdmin .php scripts
        $map = $targetUserContext ? self::USER_SCRIPT_TO_ROUTE : self::ADMIN_SCRIPT_TO_ROUTE;
        if (!isset($map[$cleanScript])) {
            return $legacyUrl;
        }

        $route = $map[$cleanScript];

        // Promote ?table={name} into path segment for /list/{table}, /edit/{table}, /editactive/{table}, /delete/{table}
        $params = [];
        if ($queryStr !== '') {
            parse_str(html_entity_decode($queryStr, ENT_QUOTES, 'UTF-8'), $params);
        }

        if (
            !$targetUserContext
            && in_array($cleanScript, ['list.php', 'edit.php', 'editactive.php', 'delete.php'], true)
            && isset($params['table'])
            && is_string($params['table'])
            && preg_match('/^[a-z]+$/', $params['table'])
        ) {
            $route .= '/' . $params['table'];
            unset($params['table']);
        }

        $rebuiltQuery = count($params) > 0 ? '?' . http_build_query($params) : '';
        return $base . $route . $rebuiltQuery . $fragment;
    }

    /**
     * Rewrite legacy .php href/action links and relative asset paths in rendered HTML.
     * Preserves contents inside <textarea> and <script> elements untouched.
     */
    public static function rewriteHtml(string $html, bool $userContext = false, string $basePath = ''): string
    {
        $base = self::normalizeBasePath($basePath);

        // Preserve <textarea> and <script> blocks verbatim so user message content / inline JS is never altered
        $preserved = [];
        $tokenPrefix = '___PFA_ROUTER_PRESERVE_' . bin2hex(random_bytes(8)) . '_';
        $html = (string) preg_replace_callback(
            '#<(textarea|script)\b[^>]*>.*?</\1>#is',
            static function (array $m) use (&$preserved, $tokenPrefix): string {
                $key = $tokenPrefix . count($preserved) . '___';
                $preserved[$key] = $m[0];
                return $key;
            },
            $html
        );

        // 1. Rewrite href="..." and action="..." targeting PostfixAdmin .php endpoints
        $html = (string) preg_replace_callback(
            '/\b(href|action)\s*=\s*(["\'])([^"\']*\.php(?:\?[^"\']*)?(?:#[^"\']*)?)\2/i',
            static function (array $m) use ($userContext, $base): string {
                $attr = $m[1];
                $quote = $m[2];
                $rawUrl = $m[3];
                $rewritten = self::url($rawUrl, $userContext, $base);
                $escaped = htmlspecialchars($rewritten, ENT_QUOTES, 'UTF-8', false);
                return $attr . '=' . $quote . $escaped . $quote;
            },
            $html
        );

        // 2. Ensure relative static assets resolve from root on multi-segment clean URLs (/edit/mailbox, /users/main)
        $html = (string) preg_replace_callback(
            '/\b(src|href)\s*=\s*(["\'])(?:\.\.\/)?((?:css|images)\/[^"\']+|jquery-[^"\']+\.js)\2/i',
            static function (array $m) use ($base): string {
                return $m[1] . '=' . $m[2] . $base . '/' . $m[3] . $m[2];
            },
            $html
        );

        if (!empty($preserved)) {
            $html = strtr($html, $preserved);
        }

        return $html;
    }

    /**
     * Set active routing context and register Location header rewriter.
     */
    public static function setContext(bool $userContext, string $basePath = ''): void
    {
        self::$currentUserContext = $userContext;
        self::$currentBasePath = self::normalizeBasePath($basePath);
    }

    public static function isUserContext(): bool
    {
        return self::$currentUserContext;
    }

    public static function getBasePath(): string
    {
        return self::$currentBasePath;
    }

    /**
     * Register PHP header callback to rewrite "Location: *.php" redirects to clean URLs.
     */
    public static function registerLocationRewriter(bool $userContext, string $basePath = ''): void
    {
        self::setContext($userContext, $basePath);

        if (function_exists('header_register_callback')) {
            header_register_callback([self::class, 'rewriteLocationHeader']);
        }
    }

    /**
     * Callback invoked by PHP right before flushing response headers.
     */
    public static function rewriteLocationHeader(): void
    {
        foreach (headers_list() as $header) {
            if (stripos($header, 'Location:') === 0) {
                $target = trim(substr($header, 9));
                if (preg_match('/[\r\n]/', $target)) {
                    break;
                }
                $rewritten = self::url($target, self::$currentUserContext, self::$currentBasePath);
                if ($rewritten !== $target && !preg_match('/[\r\n]/', $rewritten)) {
                    header('Location: ' . $rewritten, true);
                }
                break;
            }
        }
    }

    /**
     * Smarty output filter registered by PFASmarty when $CONF['clean_urls'] = 'YES'.
     *
     * @param string $source
     * @param mixed  $smarty
     * @return string
     */
    public static function smartyOutputFilter(string $source, $smarty): string
    {
        $userContext = self::$currentUserContext
            || (function_exists('authentication_has_role') && authentication_has_role('user'))
            || (isset($_SERVER['REQUEST_URI']) && preg_match('#/users(?:/|$)#', (string) $_SERVER['REQUEST_URI']) === 1);

        $basePath = self::$currentBasePath;
        if ($basePath === '' && class_exists('Config')) {
            $basePath = self::normalizeBasePath(Config::read_string('base_url_path'));
        }

        return self::rewriteHtml($source, $userContext, $basePath);
    }
}
