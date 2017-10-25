import React from 'react';
import ReactDOM from "react-dom";
import { BrowserRouter as Router, Route } from "react-router-dom";

import NavBar from "partial/navbar.jsx";
import Home from "page/home.jsx";
import About from "page/about.jsx";
import Feedback from "page/feedback.jsx";

ReactDOM.render((
  <Router>
    <div>
      <NavBar/>
      <Route exact path="/"         component={Home}/>
      <Route       path="/about"    component={About}/>
      <Route       path="/feedback" component={Feedback}/>
    </div>
  </Router>
), document.getElementById("app"));
