#include "RESTAPI.h"

string sha256(const string& str) {
    unsigned char hash[SHA256_DIGEST_LENGTH];

    SHA256_CTX sha256;
    SHA256_Init(&sha256);
    SHA256_Update(&sha256, str.c_str(), str.size());
    SHA256_Final(hash, &sha256);

    stringstream ss;

    for(int i = 0; i < SHA256_DIGEST_LENGTH; i++) {
        ss << hex << setw(2) << setfill('0') << static_cast<int>(hash[i]);
    }

    return ss.str();
}

const string secretKey = "zayakinAB320";

string createAccessToken(const string& login) {
    auto token = jwt::create()
        .set_issuer("auth_server")
        .set_type("JWT")
        .set_payload_claim("login", jwt::claim(login))
        .set_expires_at(chrono::system_clock::now() + chrono::minutes(15))
        .sign(jwt::algorithm::hs256{secretKey});
    return token;
}

string createRefreshToken(const string& login) {
    auto token = jwt::create()
        .set_issuer("auth_server")
        .set_type("JWT")
        .set_payload_claim("login", jwt::claim(login))
        .set_expires_at(chrono::system_clock::now() + chrono::hours(24))
        .sign(jwt::algorithm::hs256{secretKey});
    return token;
}

bool verifyToken(const string& token) {
    try {
        auto decoded = jwt::decode(token);

        // 1. Проверка подписи
        auto verifier = jwt::verify()
            .allow_algorithm(jwt::algorithm::hs256{secretKey})
            .with_issuer("auth_server");
        verifier.verify(decoded);

        // 2. Проверка времени истечения
        if (decoded.has_payload_claim("exp")) {
            // Получаем claim и преобразуем в std::time_t
            auto exp_claim = decoded.get_payload_claim("exp");
            std::time_t exp_time = static_cast<std::time_t>(exp_claim.to_json().get<int64_t>());

            // Сравнение с текущим временем
            auto now = std::chrono::system_clock::now();
            auto exp_point = std::chrono::system_clock::from_time_t(exp_time);

            if (now > exp_point) {
                return false; // Токен просрочен
            }
        } else {
            cerr << "Token missing 'exp' claim" << endl;
            return false;
        }

        return true;
    } catch (const exception& e) {
        cerr << "Token verification error: " << e.what() << endl;
        return false;
    }
}

// Функция для обработки ошибок БД
crow::response handle_db_error(const exception& e) {
    crow::json::wvalue response;
    response["error"] = e.what();
    return crow::response(500, response);
}

int startServer(pqxx::connection& conn) {
    // 1. Создаем приложение с CORS middleware
    crow::App<crow::CORSHandler> app;

    // 2. Настраиваем CORS политику
    auto& cors = app.get_middleware<crow::CORSHandler>();
    cors
      .global()
      .headers("Content-Type", "Authorization")
      .methods("POST"_method, "GET"_method, "PUT"_method, "DELETE"_method, "OPTIONS"_method)
      .origin("*");

    fs::create_directory("uploads");
    fs::create_directory("uploads/maps");

    CROW_ROUTE(app, "/login") //проверка входа
      ([&conn](const crow::request& req) {
          crow::response res;
        res.add_header("Content-Type", "application/json");

        if (!req.url_params.get("login") || !req.url_params.get("pswd")) {
            res.code = 400;
            res.body = "{\"error\":\"Missing login or password\"}";
            return res;
        }

        try {
            string login = req.url_params.get("login");
            string pswd = req.url_params.get("pswd");
            string hash_pswd = sha256(pswd);

            string sqlRequest = "select * from authentication where login = '" + login + "' and pswd = '" + hash_pswd + "';";
            result resBD;
            {
                nontransaction nontrans(conn);
                resBD = nontrans.exec(sqlRequest);
            }

            string responseFromDB = resBD[0][0].as<string>();
            if(!responseFromDB.empty()) {
                string accessToken = createAccessToken(login);
                string refreshToken = createRefreshToken(login);
                json token = {
                    {"success", true},
                    {"access_token", accessToken},
                    {"refresh_token", refreshToken}
                };
                res.body = token.dump();
            } else {
                res.code = 401;
                res.body = "{\"error\":\"Invalid login or password\"}";
            }
        } catch (const std::exception& e) {
            res.code = 500;
            res.body = "{\"error\":\"Database error\"}";
        }

        return res;
    });

    CROW_ROUTE(app, "/refresh")
    .methods("POST"_method)
    ([](const crow::request& req) {
        crow::response res;
        res.add_header("Content-Type", "application/json");
        res.add_header("Access-Control-Allow-Origin", "*");

        auto body = json::parse(req.body);
        string refreshToken = body["refresh_token"];
        if (verifyToken(refreshToken)) {
            auto decoded = jwt::decode(refreshToken);
            string login = decoded.get_payload_claim("login").as_string();
            string accessToken = createAccessToken(login);
            json response = {{"access_token", accessToken}};
            res.body = response.dump();
            res.code = 200;
        } else {
            json response = {{"error", "Invalid refresh token"}};
            res.body = response.dump();
            res.code = 401;
        }
        return res;
    });

    // Проверка логина
    CROW_ROUTE(app, "/loginReg")
    .methods("GET"_method)
    ([&conn](const crow::request& req){
        crow::response res;
        res.add_header("Content-Type", "application/json");
        res.add_header("Access-Control-Allow-Origin", "*");

        if (!req.url_params.get("login")) {
            json response = {{"error", "Missing login for check"}};
            res.body = response.dump();
            res.code = 400;
            return res;
        }

        string login = req.url_params.get("login");
        string sqlReq = "select * from authentication where login = '" + login + "'";
        result resBD;
        {
            nontransaction nontrans(conn);
            resBD = nontrans.exec(sqlReq);
        }

        if(resBD.empty()) {
            res.code = 200;
        } else {
            json response = {{"error", "login is exists"}};
            res.body = response.dump();
            res.code = 401;
        }
        return res;
    });

    // Логин
    CROW_ROUTE(app, "/login")
    .methods("POST"_method)
    ([&conn](const crow::request& req) {
        crow::response res;
        res.add_header("Content-Type", "application/json");
        res.add_header("Access-Control-Allow-Origin", "*");

        auto body = json::parse(req.body);
        string login = body["login"], pswd = body["pswd"];
        string hash_pswd = sha256(pswd);

        string sqlReq = "insert into authentication(login, pswd) values('" + login + "', '" + hash_pswd + "')";
        work inserUser(conn, sqlReq);
        inserUser.exec(sqlReq);
        inserUser.commit();

        json response = {{"status", "success"}};
        res.body = response.dump();
        res.code = 201;
        return res;
    });

    CROW_ROUTE(app, "/rooms").methods("GET"_method)
    ([&conn](const crow::request& req) {
        crow::response res;
        res.add_header("Content-Type", "application/json");
        res.add_header("Access-Control-Allow-Origin", "*");

        string sqlReq = "SELECT * FROM rooms";
        result resBD;
        {
            nontransaction nontrans(conn);
            resBD = nontrans.exec(sqlReq);
        }

        json response = json::array();
        for (int i = 0; i < resBD.size(); i++) {
            json item = {
                {"room_id", resBD[i][0].as<int>()},
                {"name", resBD[i][1].as<string>()}
            };

            if (!resBD[i][2].is_null()) {
                item["description"] = resBD[i][2].as<string>();
            }

            response.push_back(item);
        }
        res.body = response.dump();
        res.code = 200;
        return res;
    });

    CROW_ROUTE(app, "/rooms/<int>").methods("GET"_method)
    ([&conn](const crow::request& req, int room_id) {
        crow::response res;
        res.add_header("Content-Type", "application/json");
        res.add_header("Access-Control-Allow-Origin", "*");

        string sqlReq = "SELECT * FROM rooms WHERE room_id = " + to_string(room_id);
        result resBD;
        {
            nontransaction nontrans(conn);
            resBD = nontrans.exec(sqlReq);
        }

        if (resBD.empty()) {
            res.code = 404;
            res.body = "{\"error\":\"Room not found\"}";
        } else {
            json item = {
                {"room_id", resBD[0][0].as<int>()},
                {"name", resBD[0][1].as<string>()}
            };

            if (!resBD[0][2].is_null()) {
                item["description"] = resBD[0][2].as<string>();
            }

            res.body = item.dump();
            res.code = 200;
        }
        return res;
    });

    CROW_ROUTE(app, "/rooms").methods("POST"_method)
    ([&conn](const crow::request& req) {
        crow::response res;
        res.add_header("Content-Type", "application/json");
        res.add_header("Access-Control-Allow-Origin", "*");

        auto body = json::parse(req.body);
        if (!body.contains("token") || !body.contains("name")) {
            res.code = 400;
            res.body = "{\"error\":\"Missing required fields\"}";
            return res;
        }

        if (!verifyToken(body["token"].get<string>())) {
            res.code = 401;
            res.body = "{\"error\":\"Unauthorized\"}";
            return res;
        }

        string name = body["name"].get<string>();
        string description = body.contains("description") ? body["description"].get<string>() : "unusability";

        string sqlReq;
        if (description == "unusability") {
            sqlReq = "INSERT INTO rooms(name) VALUES ('" + name + "')";
        } else {
            sqlReq = "INSERT INTO rooms(name, description) VALUES ('" + name + "', '" + description + "')";
        }

        try {
            work insertRoom(conn, sqlReq);
            insertRoom.exec(sqlReq);
            insertRoom.commit();

            res.code = 201;
            res.body = "{\"status\":\"success\"}";
        } catch (const exception& e) {
            res.code = 500;
            res.body = "{\"error\":\"Database error\"}";
            cerr << "Ошибка при добавлении комнаты: " << e.what() << endl;
        }
        return res;
    });

    CROW_ROUTE(app, "/sensors").methods("GET"_method)
    ([&conn](const crow::request& req) {
        crow::response res;
        res.add_header("Content-Type", "application/json");
        res.add_header("Access-Control-Allow-Origin", "*");

        if (!req.url_params.get("room_id")) {
            res.code = 400;
            res.body = "{\"error\":\"room_id parameter is required\"}";
            return res;
        }

        int room_id = stoi(req.url_params.get("room_id"));
        string sqlReq = "SELECT s.*, t.name as type_name FROM sensors s "
                       "JOIN type_sensors t ON s.type_id = t.type_sens_id "
                       "WHERE s.room_id = " + to_string(room_id);

        result resBD;
        {
            nontransaction nontrans(conn);
            resBD = nontrans.exec(sqlReq);
        }

        json response = json::array();
        for (int i = 0; i < resBD.size(); i++) {
            json item = {
                {"sens_id", resBD[i][0].as<int>()},
                {"name", resBD[i][1].as<string>()},
                {"type_id", resBD[i][2].as<int>()},
                {"type_name", resBD[i][7].as<string>()},
                {"radius", resBD[i][3].as<double>()},
                {"room_id", resBD[i][4].as<int>()},
                {"pos_x", resBD[i][5].as<double>()},
                {"pos_y", resBD[i][6].as<double>()}
            };
            response.push_back(item);
        }

        res.body = response.dump();
        res.code = 200;
        return res;
    });

    CROW_ROUTE(app, "/sensors").methods("POST"_method)
    ([&conn](const crow::request& req) {
        crow::response res;
        res.add_header("Content-Type", "application/json");
        res.add_header("Access-Control-Allow-Origin", "*");

        auto body = json::parse(req.body);
        if (!body.contains("token") || !body.contains("name") || !body.contains("type_id") ||
            !body.contains("radius") || !body.contains("room_id") || !body.contains("pos_x") || !body.contains("pos_y")) {
            res.code = 400;
            res.body = "{\"error\":\"Missing required fields\"}";
            return res;
        }

        if (!verifyToken(body["token"].get<string>())) {
            res.code = 401;
            res.body = "{\"error\":\"Unauthorized\"}";
            return res;
        }
        

        string sqlReq = "INSERT INTO sensors(name, type_id, radius, room_id, pos_x, pos_y) VALUES ('" +
                       body["name"].get<string>() + "', " +
                       to_string(body["type_id"].get<int>()) + ", " +
                       to_string(body["radius"].get<double>()) + ", " +
                       to_string(body["room_id"].get<int>()) + ", " +
                       to_string(body["pos_x"].get<double>()) + ", " +
                       to_string(body["pos_y"].get<double>()) + ") RETURNING *";


        try {
            work insertSensor(conn, sqlReq);
            result resBD = insertSensor.exec(sqlReq);
            insertSensor.commit();

            json sensor = {
                {"sens_id", resBD[0][0].as<int>()},
                {"name", resBD[0][1].as<string>()},
                {"type_id", resBD[0][2].as<int>()},
                {"radius", resBD[0][3].as<double>()},
                {"room_id", resBD[0][4].as<int>()},
                {"pos_x", resBD[0][5].as<double>()},
                {"pos_y", resBD[0][6].as<double>()}
            };

            res.code = 201;
            res.body = sensor.dump();
        } catch (const exception& e) {
            res.code = 500;
            res.body = "{\"error\":\"Database error\"}";
            cerr << "Ошибка при добавлении датчика: " << e.what() << endl;
        }

        return res;
    });

    CROW_ROUTE(app, "/maps").methods("GET"_method)
    ([&conn](const crow::request& req) {
        crow::response res;
        res.add_header("Content-Type", "application/json");
        res.add_header("Access-Control-Allow-Origin", "*");

        if (!req.url_params.get("room_id")) {
            res.code = 400;
            res.body = "{\"error\":\"room_id parameter is required\"}";
            return res;
        }

        int room_id = stoi(req.url_params.get("room_id"));
        string sqlReq = "SELECT * FROM maps WHERE room_id = " + to_string(room_id);

        result resBD;
        {
            nontransaction nontrans(conn);
            resBD = nontrans.exec(sqlReq);
        }

        if (resBD.empty()) {
            res.code = 404;
            res.body = "{\"error\":\"Map not found\"}";
        } else {
            json map = {
                {"map_id", resBD[0][0].as<int>()},
                {"room_id", resBD[0][1].as<int>()},
                {"file_path", resBD[0][2].as<string>()}
            };
            res.body = map.dump();
            res.code = 200;
        }
        return res;
    });

    CROW_ROUTE(app, "/maps").methods("POST"_method)
    ([&conn](const crow::request& req) {
        crow::response res;
        res.add_header("Content-Type", "application/json");
        res.add_header("Access-Control-Allow-Origin", "*");

        crow::multipart::message file_message(req);
        if (file_message.parts.size() != 2) {
            res.code = 400;
            res.body = "{\"error\":\"Expected map file and room_id\"}";
            return res;
        }

        string room_id;
        const crow::multipart::part* file_part = nullptr;

        for (const auto& part : file_message.parts) {
            auto headers_it = part.headers.find("Content-Disposition");
            if (headers_it != part.headers.end()) {
                const auto& params = headers_it->second.params;
                if (params.find("name") != params.end()) {
                    if (params.at("name") == "room_id") {
                        room_id = part.body;
                    } else if (params.at("name") == "map") {
                        file_part = &part;
                    }
                }
            }
        }

        if (room_id.empty() || !file_part) {
            res.code = 400;
            res.body = "{\"error\":\"Both map file and room_id are required\"}";
            return res;
        }

        string filename = "map_" + room_id + "_" + to_string(time(nullptr));
        string extension = "bin";

        auto content_type_it = file_part->headers.find("Content-Type");
        if (content_type_it != file_part->headers.end()) {
            // Получаем строковое значение заголовка
            string content_type = content_type_it->second.value;
            if (content_type == "image/jpeg") extension = "jpg";
            else if (content_type == "image/png") extension = "png";
            else if (content_type == "image/gif") extension = "gif";
        }

        filename += "." + extension;
        string filepath = "uploads/maps/" + filename;

        ofstream out(filepath, ios::binary);
        out.write(file_part->body.data(), file_part->body.size());
        out.close();

        try {
            string deleteSql = "DELETE FROM maps WHERE room_id = " + room_id;
            work deleteMap(conn, deleteSql);
            deleteMap.exec(deleteSql);
            deleteMap.commit();

            string insertSql = "INSERT INTO maps(room_id, file_path) VALUES (" +
                             room_id + ", '" + filepath + "') RETURNING *";
            work insertMap(conn, insertSql);
            result resBD = insertMap.exec(insertSql);
            insertMap.commit();

            json map = {
                {"map_id", resBD[0][0].as<int>()},
                {"room_id", resBD[0][1].as<int>()},
                {"file_path", resBD[0][2].as<string>()}
            };

            res.code = 201;
            res.body = map.dump();
        } catch (const exception& e) {
            res.code = 500;
            res.body = "{\"error\":\"Database error\"}";
            cerr << "Ошибка при загрузке карты: " << e.what() << endl;
        }
        return res;
    });



    CROW_ROUTE(app, "/<string>/<int>").methods("DELETE"_method)
    ([&conn](const crow::request& req, string dataType, int id) {
        crow::response res;
        res.add_header("Content-Type", "application/json");
        res.add_header("Access-Control-Allow-Origin", "*");

        auto body = json::parse(req.body);
        if (!body.contains("token")) {
            res.code = 400;
            res.body = "{\"error\":\"Token is required\"}";
            return res;
        }

        if (!verifyToken(body["token"].get<string>())) {
            res.code = 401;
            res.body = "{\"error\":\"Unauthorized\"}";
            return res;
        }

        string type_id;
        if (dataType == "rooms") {
            type_id = "room_id";
        } else if (dataType == "sensors") {
            type_id = "sens_id";
        } else if (dataType == "maps") {
            type_id = "map_id";
        } else {
            res.code = 400;
            res.body = "{\"error\":\"Invalid data type\"}";
            return res;
        }

        string sqlReq = "DELETE FROM " + dataType + " WHERE " + type_id + " = " + to_string(id);
        try {
            work deleteObject(conn, sqlReq);
            deleteObject.exec(sqlReq);
            deleteObject.commit();

            res.code = 200;
            res.body = "{\"status\":\"success\"}";
        } catch (const exception& e) {
            res.code = 500;
            res.body = "{\"error\":\"Database error\"}";
            cerr << "Ошибка при удалении объекта: " << e.what() << endl;
        }
        return res;
    });

    CROW_ROUTE(app, "/uploads/maps/<string>")
    ([](const crow::request& req, string filename) {
        crow::response res;
        res.add_header("Content-Type", "application/json");
        res.add_header("Access-Control-Allow-Origin", "*");

        string filepath = "uploads/maps/" + filename;

        if (!fs::exists(filepath)) {
            res.code = 404;
            res.body = "{\"error\":\"File not found\"}";
            return res;
        }

        string content_type = "application/octet-stream";
        size_t dot_pos = filename.rfind('.');
        if (dot_pos != string::npos) {
            string ext = filename.substr(dot_pos + 1);
            if (ext == "jpg" || ext == "jpeg") content_type = "image/jpeg";
            else if (ext == "png") content_type = "image/png";
            else if (ext == "gif") content_type = "image/gif";
            else if (ext == "svg") content_type = "image/svg+xml";
        }

        res.set_static_file_info(filepath);
        res.add_header("Content-Type", content_type);
        res.code = 200;
        return res;
    });

    CROW_ROUTE(app, "/sensor-types").methods("GET"_method)
    ([&conn](const crow::request& req) {
        crow::response res;
        res.add_header("Content-Type", "application/json");
        res.add_header("Access-Control-Allow-Origin", "*");

        string sqlReq = "SELECT * FROM type_sensors";
        result resBD;
        {
            nontransaction nontrans(conn);
            resBD = nontrans.exec(sqlReq);
        }

        json response = json::array();
        for (int i = 0; i < resBD.size(); i++) {
            json item = {
                {"type_sens_id", resBD[i][0].as<int>()},
                {"name", resBD[i][1].as<string>()}
            };
            response.push_back(item);
        }

        res.body = response.dump();
        res.code = 200;
        return res;
    });

    CROW_ROUTE(app, "/sensors/<int>").methods("PUT"_method)
    ([&conn](const crow::request& req, int sens_id) {
        crow::response res;
        res.add_header("Content-Type", "application/json");
        res.add_header("Access-Control-Allow-Origin", "*");

        auto body = json::parse(req.body);
        if (!body.contains("token") || !body.contains("pos_x") || !body.contains("pos_y")) {
            res.code = 400;
            res.body = "{\"error\":\"Missing required fields\"}";
            return res;
        }

        if (!verifyToken(body["token"].get<string>())) {
            res.code = 401;
            res.body = "{\"error\":\"Unauthorized\"}";
            return res;
        }

        string sqlReq = "UPDATE sensors SET pos_x = " + to_string(body["pos_x"].get<double>()) +
                       ", pos_y = " + to_string(body["pos_y"].get<double>()) +
                       " WHERE sens_id = " + to_string(sens_id) + " RETURNING *";

        try {
            work updateSensor(conn, sqlReq);
            result resBD = updateSensor.exec(sqlReq);
            updateSensor.commit();

            json sensor = {
                {"sens_id", resBD[0][0].as<int>()},
                {"name", resBD[0][1].as<string>()},
                {"type_id", resBD[0][2].as<int>()},
                {"radius", resBD[0][3].as<double>()},
                {"room_id", resBD[0][4].as<int>()},
                {"pos_x", resBD[0][5].as<double>()},
                {"pos_y", resBD[0][6].as<double>()}
            };

            res.code = 200;
            res.body = sensor.dump();
        } catch (const exception& e) {
            res.code = 500;
            res.body = "{\"error\":\"Database error\"}";
            cerr << "Ошибка при обновлении датчика: " << e.what() << endl;
        }
        return res;
    });

    CROW_ROUTE(app, "/sensor-types").methods("POST"_method)
    ([&conn](const crow::request& req) {
        crow::response res;
        res.add_header("Content-Type", "application/json");
        res.add_header("Access-Control-Allow-Origin", "*");

        auto body = json::parse(req.body);
        if (!verifyToken(body["token"].get<string>())) {
            res.code = 401;
            res.body = "{\"error\":\"Unauthorized\"}";
            return res;
        }

        try {
            string sqlReq = "insert into type_sensors(name) values('" + body["name"].get<string>() + "')";
            work insertType(conn);
            insertType.exec(sqlReq);
            insertType.commit();
            res.code = 201;
            res.body = "{\"status\":\"Succes insert type sensors\"}";
            return res;
        }catch (const exception& e) {
            res.code = 500;
            res.body = "{\"error\":\"Database error\"}";
            cerr << "Ошибка при добавлении типа датчика: " << e.what() << endl;
            return res;
        }
    });

    app.port(5000).run();
    return 0;
}
