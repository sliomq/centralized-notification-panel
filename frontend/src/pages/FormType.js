import React, { useRef, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import './Form.css';

const Form = () => {
    const nameRef = useRef(null);
    const navigate = useNavigate();
    const isAuth = localStorage.getItem('isAuth');

    const handleSubmit = async (e) => {
        e.preventDefault();

        let url = 'http://localhost:5000/sensor-types';
        let token = localStorage.getItem('access_token');
        let refresh_token = localStorage.getItem('refresh_token');

        // Создаем объект данных
        const newItemData = {
            name: nameRef.current.value,
            token: token,
        };

        try {
            const response = await axios.post(url, newItemData, {
                headers: { "Content-Type": "application/json" }
            });

            console.log("Добавленный тип датчика:", response.data);
            navigate('/home');
        } catch (error) {
            if (error.response && error.response.status === 401) {
                try {
                    const responseUpdateToken = await axios.post(`http://localhost:5000/refresh`, {
                        refresh_token: refresh_token
                    }, {
                        headers: {
                            'Content-Type': 'application/json'
                        }
                    });

                    if (responseUpdateToken.status === 200) {
                        localStorage.setItem('access_token', responseUpdateToken.data.access_token);
                        token = responseUpdateToken.data.access_token;
                        newItemData.token = token; // Обновляем токен в объекте данных
                        // Повторяем запрос добавления с новым токеном
                        await handleSubmit(e);
                    } else {
                        localStorage.removeItem('isAuth');
                        localStorage.removeItem('access_token');
                        localStorage.removeItem('refresh_token');
                        navigate('/');
                    }
                } catch (refreshError) {
                    console.error("Ошибка обновления токена:", refreshError);
                    localStorage.removeItem('isAuth');
                    localStorage.removeItem('access_token');
                    localStorage.removeItem('refresh_token');
                    navigate('/');
                }
            } else {
                console.error("Ошибка создания:", error);
                alert("Ошибка при добавлении: " + error.message);
            }
        }
    };
    

    useEffect(() => {
        if (!isAuth) {
          navigate('/'); // Перенаправляем если не авторизован
          return;
        }
    });

    return (
        <div className="form-container">
            <h2>Добавить новый тип датчика</h2>
            <form onSubmit={handleSubmit}>
                <label>
                    Название:
                    <input type="text" ref={nameRef} required />
                </label>
                <br />

                <button type="submit">Добавить</button>
            </form>
        </div>
    );
};

export default Form;