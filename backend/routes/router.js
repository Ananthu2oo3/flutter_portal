const express = require('express');
const router = express.Router();


// Maintenance Portal Routes

const {getMaintenanceLogin} = require('../controllers/maintenance/maintenance_login');
const {getMaintenanceNotification} = require('../controllers/maintenance/notification');
const {getWorkOrders} = require('../controllers/maintenance/work_order');

router.post('/login', getMaintenanceLogin);
router.post('/notification', getMaintenanceNotification);
router.post('/work-orders', getWorkOrders);

module.exports = router;