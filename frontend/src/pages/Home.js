import React, { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import axios from 'axios';
import './Home.css';

const Home = () => {
  // Состояния данных
  const [dataRoom, setDataRoom] = useState([]);
  const isAuth = localStorage.getItem('isAuth');
  const navigate = useNavigate();

  // Состояния для пагинации
  const [currentPageRoom, setCurrentPageRoom] = useState(1);
  const [itemsPerPage] = useState(3);

  // Состояния для фильтров
  const [filters, setFilters] = useState({
    roomName: '',
  });

  // Загрузка данных
  const loadData = async () => {
    try {
      const [room] = await Promise.all([
        axios.get("http://localhost:5000/rooms")
      ]);
      
      setDataRoom(room.data || []);
    } catch (error) {
      console.error("Ошибка запроса:", error);
    }
  };

  // Фильтрация данных
  const filterData = (data, type) => {
    return data.filter(item => {
      return (
        item.name.toLowerCase().includes(filters.roomName.toLowerCase())
      );
    });
  };

  // Пагинация данных
  const getPaginatedData = (data, currentPage) => {
    const indexOfLastItem = currentPage * itemsPerPage;
    const indexOfFirstItem = indexOfLastItem - itemsPerPage;
    return {
      currentItems: data.slice(indexOfFirstItem, indexOfLastItem),
      totalPages: Math.ceil(data.length / itemsPerPage)
    };
  };

  // Обработчик изменения фильтров
  const handleFilterChange = (e) => {
    const { name, value } = e.target;
    setFilters(prev => ({
      ...prev,
      [name]: value
    }));
    
    setCurrentPageRoom(1);
  };

  // Применение фильтров при загрузке данных
  useEffect(() => {
    if (!isAuth) {
      navigate('/');
      return;
    }
    loadData();
  }, [isAuth, navigate]);

  // Получение отфильтрованных и пагинированных данных
  const filteredRoom = filterData(dataRoom, 'rooms');
  const paginatedRoom = getPaginatedData(filteredRoom, currentPageRoom);

  const deleteItem = async (id, dataType) => { //удаление 
    let token = localStorage.getItem('access_token');
    let refresh_token = localStorage.getItem('refresh_token');

    try {
      const responseDelete = await axios.delete(`http://localhost:5000/${dataType}/${id}`, {
        data: { token: token }, // Отправляем токен в теле запроса с ключом 'token'
        headers: {
          'Content-Type': 'application/json' // Указываем тип содержимого
        }
      });

      if (responseDelete.status === 200) {
        // Успешное удаление
        loadData();
        return;
      }

    } catch (error) {
      if (error.response && error.response.status === 401) {
        try {
          const responseUpdateToken = await axios.post(`http://localhost:5000/refresh`, {
            refresh_token: refresh_token // Отправляем refresh_token в теле запроса с ключом 'refresh_token'
          }, {
            headers: {
              'Content-Type': 'application/json' // Указываем тип содержимого
            }
          });

          if (responseUpdateToken.status === 200) {
            localStorage.setItem('access_token', responseUpdateToken.data.access_token);
            token = responseUpdateToken.data.access_token;
            // Повторяем запрос удаления с новым токеном
            await deleteItem(id, dataType);
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
        console.error("Ошибка удаления:", error);
      }
    }
  };

  const handleLogout = () => { //разлогирование
    localStorage.clear(); // Очищаем весь localStorage
    navigate('/'); // Перенаправляем на страницу входа
  };

  return (
    <div className="home">
      <div className="filters">
        <h2>Комнаты</h2>
        <div className="filters-inputs">
          <input
            type="text"
            name="roomName"
            placeholder="Название"
            value={filters.roomName}
            onChange={handleFilterChange}
          />
        </div>
      </div>
  
      {paginatedRoom.currentItems.length === 0 ? (
        <h4>Комнаты не обнаружены</h4>
      ) : (
        <>
          <ul>
            {paginatedRoom.currentItems.map(item => (
              <li key={item.room_id}>
                <Link to={`/detail/room/${item.room_id}`}>
                  {item.name}
                </Link>
                <button onClick={() => deleteItem(item.room_id, 'rooms')}>
                  Удалить
                </button>
              </li>
            ))}
          </ul>
          <div className="pagination">
            <button
              onClick={() => setCurrentPageRoom(p => Math.max(p - 1, 1))}
              disabled={currentPageRoom === 1}
            >
              Назад
            </button>
            <span>Страница {currentPageRoom} из {paginatedRoom.totalPages}</span>
            <button
              onClick={() => setCurrentPageRoom(p => p + 1)}
              disabled={currentPageRoom >= paginatedRoom.totalPages}
            >
              Вперед
            </button>
          </div>
        </>
      )}
  
      <Link to="/add" className="add-product-link">
        Добавить помещение
      </Link>
      <button onClick={handleLogout} className='exit-button'>
        Выход
      </button>
    </div>
  );
};

export default Home;