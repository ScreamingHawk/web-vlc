import React from 'react';
import { render } from 'react-dom';
import App from './components/App.jsx';
import registerServiceWorker from './service/registerServiceWorker';

import styles from './scss/main.scss';

render(
	<App />,
	document.getElementById('root')
);

//registerServiceWorker();
