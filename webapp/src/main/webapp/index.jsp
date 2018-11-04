<%@page import="java.util.*,java.nio.charset.StandardCharsets,java.nio.file.*,java.io.*"%> 
<!DOCTYPE html>
<html lang="en">
    <head>
    <style> /* set the CSS */
        .line {
                  fill: none;
                  stroke: steelblue;
                  stroke-width: 2px;
        }            
    </style>       
    </head>
    <body>  
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>   
        <script src="https://d3js.org/d3.v4.min.js"></script>
        <h1>Data usage monitor</h1>
        <div id="viz"></div>
        <%
                ServletContext sc = request.getServletContext();
                String logPath = sc.getInitParameter("DataUsageLog");
                //if (logPath != null)
                //    out.write(logPath);
                //else 
                //    out.write("No log file!");
                
                String data = "";
                List<String> lines = Collections.emptyList();  
                lines = Files.readAllLines(Paths.get(logPath), StandardCharsets.UTF_8); 
                Iterator<String> itr = lines.iterator();
                //String[] firstRow = itr.next().split(",");
                String[] firstRow = {"date","close","limit"};
                data += "[";
                String row[] = itr.next().split(",");
                data += "{" + firstRow[0]+" :\"" +row[0] + "\"";
                    for (int i=1; i<row.length; i++){
                        data += ", " + firstRow[i]+" :\"" +row[i] + "\"";
                    }
                data += "}";
                while (itr.hasNext()){
                    row = itr.next().split(",");
                    data += ",{" + firstRow[0]+" :\"" +row[0] + "\"";
                    for (int i=1; i<row.length; i++){
                        data += ", " + firstRow[i]+" :\"" +row[i] + "\"";
                    }
                    data += "}";
                }
                data += "]"; 
                //out.write("data=" + data);
        %>
        <script type="text/javascript">

            
            var w = 420, h = 420;   
            
            // set the dimensions and margins of the graph
            var margin = {top: 20, right: 20, bottom: 30, left: 50},
            width = 960 - margin.left - margin.right,
            height = 500 - margin.top - margin.bottom;

            // parse the date / time
            // See https://github.com/d3/d3-time-format
            var parseTime = d3.utcParse("%Y-%m-%d %H:%M:%S.%L");
            var parseDataQty = function( s ){
                var val = Number(s.replace('GB',''));
                return val;
            }

            // set the ranges
            var x = d3.scaleTime().range([0, width]);
            var y = d3.scaleLinear().range([height, 0]);
            // define the line
            var valueline = d3.line()
                .x(function(d) { return x(d.date); })
                .y(function(d) { return y(d.close); });

            // append the svg obgect to the viz div
            // appends a 'group' element to 'svg'
            // moves the 'group' element to the top left margin
            var svg = d3.select("#viz").append("svg")
                .attr("width", width + margin.left + margin.right)
                .attr("height", height + margin.top + margin.bottom)
                .append("g")
                .attr("transform",
                    "translate(" + margin.left + "," + margin.top + ")");

            // Get the data
            //d3.csv("data_usage.csv", function(error, data) {
            //    if (error) throw error;
            // JSP value inserted here.
            var data= <%= data %>;
            {
                // format the data
                data.forEach(function(d) {
                    d.date = parseTime(d.date);
                    d.close = parseDataQty(d.close);
                });

                // Scale the range of the data
                x.domain(d3.extent(data, function(d) { return d.date; }));
                y.domain([0, d3.max(data, function(d) { return d.close; })]);

                // Add the valueline path.
                svg.append("path")
                    .data([data])
                    .attr("class", "line")
                    .attr("d", valueline);

                // Add the X Axis
                svg.append("g")
                    .attr("transform", "translate(0," + height + ")")
                    .call(d3.axisBottom(x));

                // Add the Y Axis
                svg.append("g")
                    .call(d3.axisLeft(y));

            }
        </script>
    </body>
</html>
