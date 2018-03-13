#!/usr/bin/env node
'use strict';

process.env.NODE_ENV = process.env.NODE_ENV || 'development';

const app = require('./lib/app');
const port = app.get('port');

app.listen(port, () => app.get('log').info('Express server listening on port ' + port));
