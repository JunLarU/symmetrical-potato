package app.models;

import core.http.HttpClientSingleton;
import org.json.JSONObject;

public class LoginModel {

    public JSONObject iniciarSesion(String expediente, String nip) throws Exception {
        JSONObject body = new JSONObject();
        body.put("expediente", expediente);
        body.put("nip", nip);

        System.out.println("📡 Enviando solicitud de login:");
        System.out.println(body.toString(4));

        String response = HttpClientSingleton.getInstance()
                .post("users/login", body.toString());

        if (response == null || response.isBlank()) {
            throw new Exception("Respuesta vacía del servidor.");
        }

        JSONObject jsonResponse;
        try {
            jsonResponse = new JSONObject(response);
        } catch (Exception e) {
            throw new Exception("El servidor no devolvió un JSON válido: " + response);
        }

        return jsonResponse;
    }
}
