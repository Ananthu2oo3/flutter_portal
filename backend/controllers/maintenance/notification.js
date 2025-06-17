// const axios = require('axios');
// const xml2js = require('xml2js');

// exports.getMaintenanceLogin = async (req, res) => {
//   console.log('🔵 [1] Received login request');

//   const {username} = req.body;

//   console.log('🔵 [2] Extracted credentials:', { username });

//   const fullUrl = `${process.env.NOTIFICATION}?$filter=EmployeeId eq '${username}'`;
//   console.log('🔵 [3] Full SAP OData URL:', fullUrl);

//   const headers = {
//     'Accept': 'application/xml',
//     'Authorization': 'Basic ' + Buffer.from(`${process.env.SAP_USERNAME}:${process.env.SAP_PASSWORD}`).toString('base64'),
//     'Cookie': 'sap-usercontext=sap-client=100'
//   };

//   try {
//     const response = await axios.get(fullUrl, {
//       headers,
//       maxBodyLength: Infinity
//     });

//     console.log('🟢 [4] SAP OData response received');

//     xml2js.parseString(response.data, { explicitArray: false }, (err, result) => {
//       if (err) {
//         console.error('🔴 XML parsing error:', err);
//         return res.status(500).json({ status: 'ERROR', message: 'Failed to parse SAP response' });
//       }

//       try {

//         let entry = result.feed.entry;
//         if (Array.isArray(entry)) {
//           entry = entry[0];
//         }

//         const props = entry.content['m:properties'];
//         const id = props['d:EmployeeId'];
//         const status = props['d:EvStatus'];
//         const notification_no = props['d:NotificationNo'];

//         console.log('🧩 [5] Parsed SAP data:', { id, notification_no, status });

//         return res.status(200).json({
//           status: status,
//           notification_no: notification_no
//         });

//       } catch (parseError) {
//         console.error('🔴 Failed to extract properties:', parseError);
//         return res.status(500).json({ status: 'ERROR', message: 'Invalid SAP data structure' });
//       }
//     });

//   } catch (error) {
//     console.error('🔴 SAP OData request error:', error.response ? error.response.data : error.message);
//     res.status(500).json({
//       status: 'ERROR',
//       message: 'Failed to contact SAP OData service'
//     });
//   }
// };


const axios = require('axios');

exports.getMaintenanceNotification = async (req, res) => {
  console.log('🔵 [1] Received login request');

  const { username } = req.body;
  console.log('🔵 [2] Extracted credentials:', { username });

  const fullUrl = `${process.env.NOTIFICATION}?$filter=EmployeeId eq '${username}'`;
  console.log('🔵 [3] Full SAP OData URL:', fullUrl);

  const headers = {
    'Accept': 'application/json',
    'Authorization': 'Basic ' + Buffer.from(`${process.env.SAP_USERNAME}:${process.env.SAP_PASSWORD}`).toString('base64'),
    'Cookie': 'sap-usercontext=sap-client=100'
  };

  try {
    const response = await axios.get(fullUrl, {
      headers,
      maxBodyLength: Infinity
    });

    console.log('🟢 [4] SAP OData response received');

    const results = response.data?.d?.results || [];

    if (results.length === 0) {
      return res.status(404).json({ status: 'ERROR', message: 'No data found for this EmployeeId' });
    }

    // ✅ Use proper spacing in keys
    const data = results.map(item => ({
      "Employee ID": item.EmployeeId,
      "Notification Number": item.NotificationNo,
      "Location Account Assignment": item.LocationAccountAssignment,
      "Equipment Number": item.EquipmentNumber,
      "Malfunction Start Date": item.MalfuctionStartDate,
      "Malfunction Start Time": item.MalfuctionStartTime,
      "Planning Plant": item.MaintenancePlanningPlant,
      "Planning Group": item.MaintenancePlanningGroup,
      "Notification Type": item.NotificationType,
      "Short Text": item.ShortText,
      "Priority Type": item.PriorityType,
      "Priority": item.Priority,
      "Compilation Date": item.CompilationDate,
      "Plant Work Centre": item.PlantWorkCentre,
      "Maintenance Plant": item.MaintenancePlant
    }));

    console.log('✅ [5] Cleaned data prepared with spaces:', data);

    return res.status(200).json({
      status: 'SUCCESS',
      data: data
    });

  } catch (error) {
    console.error('🔴 SAP OData request error:', error.response ? error.response.data : error.message);
    res.status(500).json({
      status: 'ERROR',
      message: 'Failed to contact SAP OData service'
    });
  }
};
