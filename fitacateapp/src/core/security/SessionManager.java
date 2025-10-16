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

    /** Inicia la sesión guardando los datos del usuario autenticado. */
    public void startSession(JSONObject usuario) {
        this.userData = usuario;
        this.isAuthenticated = true;

        System.out.println("🔐 Sesión iniciada:");
        System.out.println(usuario.toString(4));
    }

    /** Cierra la sesión. */
    public void closeSession() {
        this.userData = null;
        this.isAuthenticated = false;
        System.out.println("🔒 Sesión cerrada.");
    }

    /** Verifica si hay sesión activa. */
    public boolean isAuthenticated() {
        return isAuthenticated;
    }

    /** Devuelve el valor de un campo del usuario (como 'Nombre', 'Correo', etc.). */
    public String get(String key) {
        return (userData != null) ? userData.optString(key, "") : "";
    }

    public JSONObject getUserData() {
        return userData;
    }

    // 👇 Nuevos métodos de ayuda según el tipo de usuario

    /** Devuelve el tipo de usuario: "Administrador" o "Usuario". */
    public String getUserType() {
        return (userData != null) ? userData.optString("Tipo", "Usuario") : "Usuario";
    }

    /** Retorna true si el usuario es administrador. */
    public boolean isAdmin() {
        return "Administrador".equalsIgnoreCase(getUserType());
    }

    /** Retorna true si el usuario es un usuario normal. */
    public boolean isUser() {
        return "Usuario".equalsIgnoreCase(getUserType());
    }
}
