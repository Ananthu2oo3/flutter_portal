const axios = require('axios');
const xml2js = require('xml2js');

exports.getMaintenanceLogin = async (req, res) => {
  console.log('🔵 [1] Received login request');

  const { username, password } = req.body;

  console.log('🔵 [2] Extracted credentials:', { username, password });

  const fullUrl = `${process.env.LOGIN}?$filter=EmployeeId eq '${username}' and Password eq '${password}'&$format=xml`;
  console.log('🔵 [3] Full SAP OData URL:', fullUrl);

  const headers = {
    'Accept': 'application/xml',
    'Authorization': 'Basic ' + Buffer.from(`${process.env.SAP_USERNAME}:${process.env.SAP_PASSWORD}`).toString('base64'),
    'Cookie': 'sap-usercontext=sap-client=100'
  };

  try {
    const response = await axios.get(fullUrl, {
      headers,
      maxBodyLength: Infinity
    });

    console.log('🟢 [4] SAP OData response received');

    xml2js.parseString(response.data, { explicitArray: false }, (err, result) => {
      if (err) {
        console.error('🔴 XML parsing error:', err);
        return res.status(500).json({ status: 'ERROR', message: 'Failed to parse SAP response' });
      }

      try {
        // 🔑 Correct path: feed -> entry -> content -> m:properties
        let entry = result.feed.entry;

        // entry can be a single object or an array
        if (Array.isArray(entry)) {
          entry = entry[0];
        }

        const props = entry.content['m:properties'];
        const id = props['d:EmployeeId'];
        const status = props['d:EvStatus'];
        const notification_no = props['d:NotificationNo'];

        console.log('🧩 [5] Parsed SAP data:', { id, notification_no, status });

        return res.status(200).json({
          status: status
        });

      } catch (parseError) {
        console.error('🔴 Failed to extract properties:', parseError);
        return res.status(500).json({ status: 'ERROR', message: 'Invalid SAP data structure' });
      }
    });

  } catch (error) {
    console.error('🔴 SAP OData request error:', error.response ? error.response.data : error.message);
    res.status(500).json({
      status: 'ERROR',
      message: 'Failed to contact SAP OData service'
    });
  }
};
