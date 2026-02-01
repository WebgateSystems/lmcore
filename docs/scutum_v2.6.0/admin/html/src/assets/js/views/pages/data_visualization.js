scutum.pages.data_visualization = {};
scutum.pages.data_visualization.init = function () {
    scutum.require(
        ['datatables', 'd3', 'billboard'],
        function () {
            $dt = $('#dataVis-table').DataTable({
                "scrollY": "200px",
                "scrollCollapse": true,
                "paging": false
            });
            var chart = scutum.pages.data_visualization.chartInit($dt)
            scutum.$doc.on('sc-sidebar:toggle', function () {
                chart.flush(true);
            });
            var timer;
            $dt.on("draw", function () {
                clearTimeout(timer);
                timer = setTimeout(function () {
                    var tableData = scutum.pages.data_visualization.getTableData($dt);
                    var population = ["Population (2017)"]
                    tableData[1].forEach(function(item) {
                        population.push(item)
                    })
                    var density = ["Density (P/Km2)"]
                    tableData[2].forEach(function(item) {
                        density.push(item)
                    })
                    chart.load({
                        columns: [
                            population,
                            density
                        ]
                    });
                    chart.config("axis.x.categories", tableData[0], true);
                }, 50)
            });
        },
        false
    );
}

scutum.pages.data_visualization.getTableData = function (table) {
    var dataArray = []
    var countryArray = []
    var populationArray = []
    var densityArray = []
    table.rows({search: "applied"}).every(function () {
        var data = this.data();
        countryArray.push(data[0]);
        populationArray.push(parseInt(data[1].replace(/\,/g, "")));
        densityArray.push(parseInt(data[2].replace(/\,/g, "")));
    });
    dataArray.push(countryArray, populationArray, densityArray);
    return dataArray;
}
scutum.pages.data_visualization.chartInit = function ($dt) {
    var tableData = scutum.pages.data_visualization.getTableData($dt);

    var population = ["Population (2017)"]
    tableData[1].forEach(function(item) {
        population.push(item)
    })
    var density = ["Density (P/Km2)"]
    tableData[2].forEach(function(item) {
        density.push(item)
    })
    return bb.generate({
        data: {
            columns: [
                population,
                density
            ],
            types: {
                "Population (2017)": 'bar',
                "Density (P/Km2)": "spline"
            },
            axes: {
                "Population (2017)": "y",
                "Density (P/Km2)": "y2"
            },
            colors: {
                "Population (2017)": scutum.helpers.colors.multi[6],
                "Density (P/Km2)": scutum.helpers.colors.multi[1]
            }
        },
        axis: {
            x: {
                type: "category",
                categories: tableData[0],
                tick: {
                    fit: true,
                    autorotate: true,
                    rotate: -45,
                    multiline: false,
                    culling: false
                }
            },
            y: {
                label: 'Population (2017)',
                tick: {
                    format: function(x) {
                        return x/1000000 + ' M';
                    }
                }
            },
            y2: {
                label: 'Density (P/Km²)',
                show: true,
                tick: {
                    format: function(x) {
                        return x;
                    }
                }
            }
        },
        padding: {
            bottom: 80
        },
        tooltip: {
            format: {
                title: function (d) {
                    return tableData[0][d];
                },
                value: function (value, ratio, id) {
                    return id === "Population (2017)" ? Math.round(value/1000000) + 'M' : value;
                }
            }
        },
        onrendered: function() {
            var column1 = $dt.column(1)
            var column2 = $dt.column(2)
            if(this.hiddenTargetIds.includes('Population (2017)')) {
                column1.visible(false)
            } else {
                column1.visible(true)
            }
            if(this.hiddenTargetIds.includes('Density (P/Km2)')) {
                column2.visible(false)
            } else {
                column2.visible(true)
            }
        },
        render: {
            lazy: false
        },
        bindto: "#dataVis-chart"
    });
}
