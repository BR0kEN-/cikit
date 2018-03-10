#!/usr/bin/env node
'use strict';

const app = require('./lib/app');
const port = app.get('port');

app.listen(port, () => app.get('log').info('Express server listening on port ' + port));
