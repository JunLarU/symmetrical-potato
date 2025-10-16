package core.security;

import org.json.JSONObject;

/**
 * Singleton seguro para gestionar la sesión del usuario en memoria.
 */
public class SessionManager {

    private static SessionManager instance;
    private JSONObject userData;
    private boolean isAuthenticated = false;

    private SessionManager() {}

    public static synchronized SessionManager getInstance() {
        if (instance == null) {
            instance = new SessionManager();
        }
        return instance;
    }

    /**
     * Inicia la sesión guardando los datos del usuario autenticado.
     * @param usuario JSON con los datos del usuario desde el servidor.
     */
    public void startSession(JSONObject usuario) {
        this.userData = usuario;
        this.isAuthenticated = true;

        System.out.println("🔐 Sesión iniciada correctamente:");
        System.out.println(usuario.toString(4));
    }

    /**
     * Cierra la sesión limpiando todos los datos del usuario en memoria.
     */
    public void closeSession() {
        if (this.isAuthenticated) {
            System.out.println("🔒 Cerrando sesión del usuario: " + get("Nombre") + " (" + get("Tipo") + ")");
        }
        this.userData = null;
        this.isAuthenticated = false;
        System.out.println("✅ Sesión cerrada correctamente.");
    }

    /**
     * Verifica si hay una sesión activa.
     * @return true si el usuario ha iniciado sesión.
     */
    public boolean isAuthenticated() {
        return isAuthenticated;
    }

    /**
     * Devuelve el valor de un campo del usuario (por ejemplo 'Nombre', 'Correo', 'Expediente').
     */
    public String get(String key) {
        return (userData != null) ? userData.optString(key, "") : "";
    }

    /**
     * Devuelve todo el JSON de datos del usuario.
     */
    public JSONObject getUserData() {
        return userData;
    }

    // --- Métodos auxiliares según tipo de usuario ---

    /** Devuelve el tipo de usuario: "Administrador" o "Usuario". */
    public String getUserType() {
        return (userData != null) ? userData.optString("Tipo", "Usuario") : "Usuario";
    }

    /** Retorna true si el usuario actual es administrador. */
    public boolean isAdmin() {
        return "Administrador".equalsIgnoreCase(getUserType());
    }

    /** Retorna true si el usuario actual es un usuario normal. */
    public boolean isUser() {
        return "Usuario".equalsIgnoreCase(getUserType());
    }
}
