package app.models;

import core.http.HttpClientSingleton;
import org.json.JSONObject;

public class TestModel {

    public JSONObject sendIncrementRequest(int numero) throws Exception {
        JSONObject body = new JSONObject();
        body.put("numero", numero);

        // Enviamos al endpoint relativo (NO toda la URL)
        String response = HttpClientSingleton.getInstance()
                .post("test/increment", body.toString());

        return new JSONObject(response);
    }
}
