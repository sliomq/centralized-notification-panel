from flask import Flask, request, jsonify
import psycopg2
import json
import os

app = Flask(__name__)

# Получаем путь к директории, в которой находится пользователь
script_directory = os.path.dirname(os.path.abspath(__file__))

# Изменяем текущую рабочую директорию на текущую (во избежание ошибок с рабочей директорией)
os.chdir(script_directory)

def conn_to_db():
    try:
        with open("config.json", "r") as file:
            data = json.load(file)
    except:
        print("Не обнаружен конфигурационный файл")
        return -1

    try:
        conn = psycopg2.connect(
            host=data["host"],
            port=data["port"],
            database=data["dbname"],
            user=data["user"],
            password=data["pswd"]
        )
        return conn
    except:
        print("Ошибка подключения к БД")
        return -2

@app.route('/reg', methods=['POST'])
def register_user():
    data = request.json
    login = data.get('login')
    password = data.get('password')
    surname = data.get('surname')
    name = data.get('name')
    patronymic = data.get('patronymic', None)

    conn = conn_to_db()
    if conn == -1 or conn == -2:
        return jsonify({"error": "Ошибка подключения к базе данных"}), 500

    try:
        with conn.cursor() as cursor:
            # Проверка на существование логина
            cursor.execute("SELECT 1 FROM authentication WHERE %s = ANY(login)", (login,))
            if cursor.fetchone():
                return jsonify({"error": "Логин уже существует"}), 400

            # Добавление пользователя
            cursor.execute("INSERT INTO users (surname, name, patronymic) VALUES (%s, %s, %s) RETURNING id",
                           (json.dumps([surname]), json.dumps([name]), json.dumps([patronymic])))
            user_id = cursor.fetchone()[0]

            # Добавление аутентификационных данных
            cursor.execute("INSERT INTO authentication (login, pswd, user_id) VALUES (%s, %s, %s)",
                           (json.dumps([login]), json.dumps([password]), user_id))

            conn.commit()
            return jsonify({"message": "Пользователь успешно зарегистрирован"}), 201
    except Exception as e:
        conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

@app.route('/auth', methods=['GET'])
def authenticate_user():
    login = request.args.get('login')
    password = request.args.get('password')

    conn = conn_to_db()
    if conn == -1 or conn == -2:
        return jsonify({"error": "Ошибка подключения к базе данных"}), 500

    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT 1 FROM authentication WHERE %s = ANY(login) AND %s = ANY(pswd)",
                           (login, password))
            if cursor.fetchone():
                return jsonify({"message": "Аутентификация успешна"}), 200
            else:
                return jsonify({"error": "Incorrect login or pswd"}), 401
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

@app.route('/schema', methods=['GET', 'POST', 'DELETE', 'PUT'])
def handle_schema():
    if request.method == 'GET':
        floor_id = request.args.get('floor_id')

        conn = conn_to_db()
        if conn == -1 or conn == -2:
            return jsonify({"error": "Ошибка подключения к базе данных"}), 500

        try:
            with conn.cursor() as cursor:
                cursor.execute("""
                    SELECT fs.schema, s.id, s.name, s.radius, s.status_id, s.pos_x, s.pos_y
                    FROM floors_schema fs
                    LEFT JOIN sensors s ON fs.floor_id = s.floor_id
                    WHERE fs.floor_id = %s
                """, (floor_id,))
                result = cursor.fetchall()
                schema_data = result[0][0] if result else None
                sensors = [{
                    "id": row[1],
                    "name": row[2],
                    "radius": row[3],
                    "status_id": row[4],
                    "pos_x": row[5],
                    "pos_y": row[6]
                } for row in result]

                return jsonify({"schema": schema_data, "sensors": sensors}), 200
        except Exception as e:
            return jsonify({"error": str(e)}), 500
        finally:
            conn.close()

    elif request.method == 'POST':
        data = request.json
        floor_id = data.get('floor_id')
        schema_data = data.get('schema_data')

        conn = conn_to_db()
        if conn == -1 or conn == -2:
            return jsonify({"error": "Ошибка подключения к базе данных"}), 500

        try:
            with conn.cursor() as cursor:
                cursor.execute("INSERT INTO floors_schema (floor_id, schema) VALUES (%s, %s)",
                               (floor_id, schema_data))
                conn.commit()
                return jsonify({"message": "Схема этажа успешно добавлена"}), 201
        except Exception as e:
            conn.rollback()
            return jsonify({"error": str(e)}), 500
        finally:
            conn.close()

    elif request.method == 'DELETE':
        floor_id = request.args.get('floor_id')

        conn = conn_to_db()
        if conn == -1 or conn == -2:
            return jsonify({"error": "Ошибка подключения к базе данных"}), 500

        try:
            with conn.cursor() as cursor:
                cursor.execute("DELETE FROM floors_schema WHERE floor_id = %s", (floor_id,))
                cursor.execute("DELETE FROM sensors WHERE floor_id = %s", (floor_id,))
                cursor.execute("DELETE FROM floors WHERE id = %s", (floor_id,))
                conn.commit()
                return jsonify({"message": "Этаж и связанные датчики успешно удалены"}), 200
        except Exception as e:
            conn.rollback()
            return jsonify({"error": str(e)}), 500
        finally:
            conn.close()

    elif request.method == 'PUT':
        data = request.json
        floor_id = data.get('floor_id')
        schema_data = data.get('schema_data')

        conn = conn_to_db()
        if conn == -1 or conn == -2:
            return jsonify({"error": "Ошибка подключения к базе данных"}), 500

        try:
            with conn.cursor() as cursor:
                cursor.execute("UPDATE floors_schema SET schema = %s WHERE floor_id = %s",
                               (schema_data, floor_id))
                conn.commit()
                return jsonify({"message": "Схема этажа успешно обновлена"}), 200
        except Exception as e:
            conn.rollback()
            return jsonify({"error": str(e)}), 500
        finally:
            conn.close()

@app.route('/sensor', methods=['POST', 'DELETE', 'PUT'])
def handle_sensor():
    if request.method == 'POST':
        data = request.json
        name = data.get('name')
        radius = data.get('radius')
        status_id = data.get('status_id')
        floor_id = data.get('floor_id')
        pos_x = data.get('pos_x')
        pos_y = data.get('pos_y')

        conn = conn_to_db()
        if conn == -1 or conn == -2:
            return jsonify({"error": "Ошибка подключения к базе данных"}), 500

        try:
            with conn.cursor() as cursor:
                cursor.execute("INSERT INTO sensors (name, radius, status_id, floor_id, pos_x, pos_y) VALUES (%s, %s, %s, %s, %s, %s)",
                               (json.dumps([name]), radius, status_id, floor_id, pos_x, pos_y))
                conn.commit()
                return jsonify({"message": "Датчик успешно добавлен"}), 201
        except Exception as e:
            conn.rollback()
            return jsonify({"error": str(e)}), 500
        finally:
            conn.close()

    elif request.method == 'DELETE':
        sensor_id = request.args.get('sensor_id')

        conn = conn_to_db()
        if conn == -1 or conn == -2:
            return jsonify({"error": "Ошибка подключения к базе данных"}), 500

        try:
            with conn.cursor() as cursor:
                cursor.execute("DELETE FROM sensors WHERE id = %s", (sensor_id,))
                conn.commit()
                return jsonify({"message": "Датчик успешно удален"}), 200
        except Exception as e:
            conn.rollback()
            return jsonify({"error": str(e)}), 500
        finally:
            conn.close()

    elif request.method == 'PUT':
        data = request.json
        sensor_id = data.get('sensor_id')
        name = data.get('name')
        radius = data.get('radius')
        status_id = data.get('status_id')
        floor_id = data.get('floor_id')
        pos_x = data.get('pos_x')
        pos_y = data.get('pos_y')

        conn = conn_to_db()
        if conn == -1 or conn == -2:
            return jsonify({"error": "Ошибка подключения к базе данных"}), 500

        try:
            with conn.cursor() as cursor:
                cursor.execute("""
                    UPDATE sensors
                    SET name = %s, radius = %s, status_id = %s, floor_id = %s, pos_x = %s, pos_y = %s
                    WHERE id = %s
                """, (json.dumps([name]), radius, status_id, floor_id, pos_x, pos_y, sensor_id))
                conn.commit()
                return jsonify({"message": "Данные датчика успешно обновлены"}), 200
        except Exception as e:
            conn.rollback()
            return jsonify({"error": str(e)}), 500
        finally:
            conn.close()

@app.route('/floor', methods=['POST'])
def add_floor():
    data = request.json
    num = data.get('num')
    description = data.get('description', None)

    conn = conn_to_db()
    if conn == -1 or conn == -2:
        return jsonify({"error": "Ошибка подключения к базе данных"}), 500

    try:
        with conn.cursor() as cursor:
            cursor.execute("INSERT INTO floors (num, description) VALUES (%s, %s)",
                           (num, description))
            conn.commit()
            return jsonify({"message": "Этаж успешно добавлен"}), 201
    except Exception as e:
        conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

if __name__ == '__main__':
    app.run(debug=True)
