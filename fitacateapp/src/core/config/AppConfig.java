package core.config;

public class AppConfig {

    // Modo de ejecución (útil si luego tienes entornos dev/staging/prod)
    public static final boolean DEBUG = true;

    // URL base del servidor PHP
    public static final String SERVER_URL = DEBUG
            ? "http://localhost/api/"   // Desarrollo local
            : "https://api.dealbo.com/api/";             // Producción

    // Timeout de conexión en segundos
    public static final int CONNECTION_TIMEOUT = 10;

    // Control sobre certificados SSL autofirmados
    public static final boolean ALLOW_SELF_SIGNED_SSL = DEBUG;
}
