import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Home from './pages/Home';
//import Detail from './pages/Detail';
import Form from './pages/Form';
import Registation from './pages/Registration';
import Authentication from './pages/Authentication';
import RoomDetail from './pages/RoomDetail';

const App = () => {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Authentication />} />
        <Route path="/reg" element={<Registation />}/>
        <Route path="/home" element={<Home />} />
        <Route path="/add" element={<Form />} />
        <Route path="/detail/room/:room_id" element={<RoomDetail />} />
      </Routes>
    </Router>
  );
};

export default App;