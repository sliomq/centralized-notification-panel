import React, { useState, useEffect, useRef, useCallback } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import axios from 'axios';
import './RoomDetail.css';

const RoomDetail = () => {
  const { room_id } = useParams();
  const navigate = useNavigate();
  const canvasRef = useRef(null);
  
  const [room, setRoom] = useState(null);
  const [sensors, setSensors] = useState([]);
  const [mapImage, setMapImage] = useState(null);
  const [selectedSensor, setSelectedSensor] = useState(null);
  const [isDragging, setIsDragging] = useState(false);
  const [dragOffset, setDragOffset] = useState({ x: 0, y: 0 });
  const [hasChanges, setHasChanges] = useState(false);
  const [showSensorForm, setShowSensorForm] = useState(false);
  const [newSensor, setNewSensor] = useState({
    name: '',
    type_id: 1,
    radius: 1.0
  });
  const [sensorTypes, setSensorTypes] = useState([]);
  const [scale, setScale] = useState(1.0);

  const getTokens = () => {
        return {
        token: localStorage.getItem('access_token'),
        refresh_token: localStorage.getItem('refresh_token')
        };
    };

    const loadRoomData = useCallback(async () => {
        try {
            const { token } = getTokens();
            const [roomRes, sensorsRes] = await Promise.all([
                axios.get(`http://localhost:5000/rooms/${room_id}`, { data: { token } }),
                axios.get(`http://localhost:5000/sensors?room_id=${room_id}`, { data: { token } }),
            ]);

            setRoom(roomRes.data);
            setSensors(sensorsRes.data);

            // Запрос карты
            try {
                const mapRes = await axios.get(`http://localhost:5000/maps?room_id=${room_id}`, { data: { token } });
                const img = new Image();
                img.src = `http://localhost:5000/${mapRes.data.file_path}`;
                img.onload = () => setMapImage(img);
            } catch (error) {
                if (error.response && error.response.status === 404) {
                    console.warn("Карта не найдена, вы можете добавить новую карту."); // Логирование
                    setMapImage(null); // Или установите состояние, чтобы показать, что карты нет
                } else {
                    console.error("Ошибка загрузки карты:", error);
                }
            }
        } catch (error) {
            console.error("Ошибка загрузки данных:", error);
        }
    }, [room_id]);


  useEffect(() => {
    loadRoomData();
  }, [loadRoomData]);

  // Отрисовка карты и датчиков на canvas
  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    
    if (mapImage) {
      canvas.width = mapImage.width * scale;
      canvas.height = mapImage.height * scale;
      ctx.drawImage(mapImage, 0, 0, canvas.width, canvas.height);
      
      sensors.forEach(sensor => {
        const x = sensor.pos_x * scale;
        const y = sensor.pos_y * scale;
        const radius = sensor.radius * scale;
        
        ctx.beginPath();
        ctx.arc(x, y, radius, 0, Math.PI * 2);
        ctx.fillStyle = selectedSensor?.sens_id === sensor.sens_id ? 'rgba(0, 255, 0, 0.5)' : 'rgba(255, 0, 0, 0.5)';
        ctx.fill();
        ctx.stroke();
        
        ctx.fillStyle = '#000';
        ctx.font = '12px Arial';
        ctx.textAlign = 'center';
        ctx.fillText(sensor.name, x, y - radius - 5);
      });
    }
  }, [mapImage, sensors, selectedSensor, scale]);

  const handleCanvasMouseDown = (e) => {
    if (!mapImage) return;
    
    const canvas = canvasRef.current;
    const rect = canvas.getBoundingClientRect();
    const x = (e.clientX - rect.left) / scale;
    const y = (e.clientY - rect.top) / scale;
    
    const clickedSensor = sensors.find(sensor => {
      const distance = Math.sqrt(
        Math.pow(x - sensor.pos_x, 2) + 
        Math.pow(y - sensor.pos_y, 2)
      );
      return distance <= sensor.radius;
    });
    
    if (clickedSensor) {
      setSelectedSensor(clickedSensor);
      setIsDragging(true);
      setDragOffset({
        x: x - clickedSensor.pos_x,
        y: y - clickedSensor.pos_y
      });
    } else {
      setSelectedSensor(null);
    }
  };

  const handleCanvasMouseMove = (e) => {
    if (!isDragging || !selectedSensor || !mapImage) return;
    
    const canvas = canvasRef.current;
    const rect = canvas.getBoundingClientRect();
    const x = (e.clientX - rect.left) / scale;
    const y = (e.clientY - rect.top) / scale;

    const updatedSensors = sensors.map(sensor => {
      if (sensor.sens_id === selectedSensor.sens_id) {
        return {
          ...sensor,
          pos_x: x - dragOffset.x,
          pos_y: y - dragOffset.y
        };
      }
      return sensor;
    });

    setSensors(updatedSensors);
    setHasChanges(true);
  };

  const handleCanvasMouseUp = () => {
    setIsDragging(false);
  };

  // Сохранение изменений позиций датчиков
  const saveChanges = async () => {
    if (!hasChanges) return; // Если изменений нет, ничего не делать
    try {
      const { token } = getTokens();
      
      const updatedSensors = sensors.filter(sensor => {
        const original = sensors.find(s => s.sens_id === sensor.sens_id);
        return sensor.pos_x !== original.pos_x || sensor.pos_y !== original.pos_y;
      });
      
      for (const sensor of updatedSensors) {
        await axios.put(`http://localhost:5000/sensors/${sensor.sens_id}`, {
          pos_x: sensor.pos_x,
          pos_y: sensor.pos_y,
          token: token
        });
      }
      
      setHasChanges(false);
      alert('Изменения сохранены успешно!');
    } catch (error) {
      console.error("Ошибка сохранения:", error);
      if (error.response && error.response.status === 401) {
        handleLogout();
      }
    }
  };

  // Удаление датчика
  const deleteSensor = async (sensorId) => {
    if (window.confirm("Вы уверены, что хотите удалить этот датчик?")) {
      try {
        const { token } = getTokens();
        await axios.delete(`http://localhost:5000/sensors/${sensorId}`, {
          data: { token: token }
        });
        
        setSensors(sensors.filter(s => s.sens_id !== sensorId));
        setSelectedSensor(null);
      } catch (error) {
        console.error("Ошибка удаления:", error);
        if (error.response && error.response.status === 401) {
          handleLogout();
        }
      }
    }
  };

  // Добавление нового датчика
  const handleAddSensor = () => {
    setShowSensorForm(true);
  };

  const handleSensorFormChange = (e) => {
    const { name, value } = e.target;
    setNewSensor(prev => ({
      ...prev,
      [name]: name === 'type_id' || name === 'radius' ? parseFloat(value) : value
    }));
  };

  const submitNewSensor = async (e) => {
    e.preventDefault();
    try {
      const { token } = getTokens();
      
      const response = await axios.post('http://localhost:5000/sensors', {
        name: newSensor.name,
        type_id: newSensor.type_id,
        radius: newSensor.radius,
        room_id: room_id,
        pos_x: 50, // Позиция по умолчанию
        pos_y: 50, // Позиция по умолчанию
        token: token
      });
      
      setSensors([...sensors, response.data]);
      setShowSensorForm(false);
      setNewSensor({
        name: '',
        type_id: 1,
        radius: 1.0
      });
    } catch (error) {
      console.error("Ошибка добавления датчика:", error);
      if (error.response && error.response.status === 401) {
        handleLogout();
      }
    }
  };

  const handleMapUpload = async (e) => {
    const file = e.target.files[0];
    if (!file) return;
    
    try {
      const formData = new FormData();
      formData.append('map', file);
      formData.append('room_id', room_id);
      
      const { token } = getTokens();
      const response = await axios.post('http://localhost:5000/maps', formData, {
        headers: {
          'Content-Type': 'multipart/form-data'
        },
          data: { token: token }
      });
      
      const img = new Image();
      img.src = `http://localhost:5000/${response.data.file_path}`;
      img.onload = () => setMapImage(img);
    } catch (error) {
      console.error("Ошибка загрузки карты:", error);
    }
  };

  const handleLogout = useCallback(() => {
    localStorage.clear();
    navigate('/');
  }, [navigate]);

  if (!room) {
    return <div>Загрузка...</div>;
  }

  return (
    <div className="room-detail">
      <div className="room-header">
        <h2>{room.name}</h2>
        {room.description && <p>{room.description}</p>}
      </div>
      
      <div className="map-container">
        <div className="map-controls">
          <label className="upload-map-btn">
            Загрузить карту
            <input 
              type="file" 
              accept="image/*" 
              onChange={handleMapUpload}
              style={{ display: 'none' }}
            />
          </label>
          
          <div className="zoom-controls">
            <button onClick={() => setScale(prev => Math.min(prev + 0.1, 2.0))}>+</button>
            <button onClick={() => setScale(prev => Math.max(prev - 0.1, 0.5))}>-</button>
            <span>Масштаб: {Math.round(scale * 100)}%</span>
          </div>
        </div>
        
        <canvas
          ref={canvasRef}
          onMouseDown={handleCanvasMouseDown}
          onMouseMove={handleCanvasMouseMove}
          onMouseUp={handleCanvasMouseUp}
          onMouseLeave={handleCanvasMouseUp}
        />
      </div>
      
      <div className="sensor-controls">
        <button onClick={handleAddSensor}>Добавить датчик</button>
        {selectedSensor && (
          <>
            <button onClick={() => deleteSensor(selectedSensor.sens_id)}>Удалить датчик</button>
            <div className="sensor-info">
              <h4>Информация о датчике:</h4>
              <p>Название: {selectedSensor.name}</p>
              <p>Тип: {selectedSensor.type_name}</p>
              <p>Радиус: {selectedSensor.radius} м</p>
              <p>Позиция: ({selectedSensor.pos_x.toFixed(2)}, {selectedSensor.pos_y.toFixed(2)})</p>
            </div>
          </>
        )}
        {hasChanges && (
          <button onClick={saveChanges} className="save-changes-btn">
            Сохранить изменения
          </button>
        )}
      </div>
      
      {showSensorForm && (
        <div className="sensor-form-modal">
          <div className="sensor-form-content">
            <h3>Добавить новый датчик</h3>
            <form onSubmit={submitNewSensor}>
              <div className="form-group">
                <label>Название:</label>
                <input
                  type="text"
                  name="name"
                  value={newSensor.name}
                  onChange={handleSensorFormChange}
                  required
                />
              </div>
              
              <div className="form-group">
                <label>Тип датчика:</label>
                <select
                  name="type_id"
                  value={newSensor.type_id}
                  onChange={handleSensorFormChange}
                >
                  {sensorTypes.map(type => (
                    <option key={type.type_sens_id} value={type.type_sens_id}>
                      {type.name}
                    </option>
                  ))}
                </select>
              </div>
              
              <div className="form-group">
                <label>Радиус действия (м):</label>
                <input
                  type="number"
                  name="radius"
                  min="0.1"
                  step="0.1"
                  value={newSensor.radius}
                  onChange={handleSensorFormChange}
                  required
                />
              </div>
              
              <div className="form-buttons">
                <button type="submit">Добавить</button>
                <button type="button" onClick={() => setShowSensorForm(false)}>
                  Отмена
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
      
      <button onClick={handleLogout} className="logout-btn">
        Выход
      </button>
    </div>
  );
};

export default RoomDetail;
