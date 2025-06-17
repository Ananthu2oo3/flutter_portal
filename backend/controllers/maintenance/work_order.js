const axios = require('axios');
const xml2js = require('xml2js');

exports.getWorkOrders = async (req, res) => {
  console.log('🔵 [1] Received work order request');

  const { username } = req.body;
  console.log('🔵 [2] Extracted Employee ID:', username);

  const fullUrl = `${process.env.WORK_ORDER}?$filter=EmployeeId eq '${username}'`;
  console.log('🔵 [3] Full SAP OData URL:', fullUrl);

  const headers = {
    'Accept': 'application/atom+xml',
    'Authorization': 'Basic ' + Buffer.from(`${process.env.SAP_USERNAME}:${process.env.SAP_PASSWORD}`).toString('base64'),
    'Cookie': 'sap-usercontext=sap-client=100'
  };

  try {
    const response = await axios.get(fullUrl, {
      headers,
      maxBodyLength: Infinity
    });

    console.log('🟢 [4] SAP OData XML response received');

    const xml = response.data;

    // Parse the Atom XML to JS object
    const parser = new xml2js.Parser({
      explicitArray: false, // flatten arrays where possible
      ignoreAttrs: false
    });

    parser.parseString(xml, (err, result) => {
      if (err) {
        console.error('🔴 XML Parsing error:', err);
        return res.status(500).json({
          status: 'ERROR',
          message: 'Failed to parse SAP OData XML'
        });
      }

      // Extract <entry> elements safely
      const entries = result.feed.entry || [];
      const list = Array.isArray(entries) ? entries : [entries];

      if (list.length === 0 || !entries) {
        return res.status(404).json({
          status: 'ERROR',
          message: 'No Work Orders found for this Employee ID'
        });
      }

      // Map each entry's m:properties to user-friendly JSON
      const data = list.map(item => {
        const props = item.content['m:properties'];

        return {
          "Order Number": props['d:OrderNo'],
          "Order Type": props['d:OrderType'],
          "Order Description": props['d:OrderDescription'],
          "Created On": props['d:CreatedOn'],
          "Created By": props['d:CreatedBy'],
          "Last Changed By": props['d:LastChangedBy'],
          "Company Code": props['d:CompanyCode'],
          "Plant": props['d:Plant'],
          "Object Number": props['d:ObjectNo'],
          "Routing Operation Number": props['d:RoutingNoOperation'],
          "Basic Start Date": props['d:BasicStartDate'],
          "Basic Finish Date": props['d:BasicFinishDate'],
          "Activity Number": props['d:ActivityNo'],
          "Operation Short Text": props['d:OperationShortText'],
          "Work Centre": props['d:WorkCentre'],
          "Employee ID": props['d:EmployeeId'],
          "Notification Number": props['d:NotificationNo']
        };
      });

      console.log('✅ [5] Work Order data with spaces:', data);

      res.status(200).json({
        status: 'SUCCESS',
        count: data.length,
        data: data
      });
    });

  } catch (error) {
    console.error('🔴 SAP OData request error:', error.response ? error.response.data : error.message);
    res.status(500).json({
      status: 'ERROR',
      message: 'Failed to contact SAP OData service'
    });
  }
};
