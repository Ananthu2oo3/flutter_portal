const express = require('express');
const router = express.Router();


// Maintenance Portal Routes

const {getMaintenanceLogin} = require('../controllers/maintenance/maintenance_login');

router.post('/login', getMaintenanceLogin);

module.exports = router;