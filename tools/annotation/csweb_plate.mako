<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
   
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-type" content="text/html;charset=UTF-8" />
		<title>HBC</title>
		
		## javascript provided in Cytoscape Web package
		## filenames for json.js,AC_OETags.js, cytoscapeweb.js
		<script type="text/javascript" src="json2.js"></script>
        <script type="text/javascript" src="AC_OETags.js"></script>
        <script type="text/javascript" src="cytoscapeweb.js"></script>
        
		## definition of network and javascript actions
		<script type="text/javascript">
			
			window.onload = function() {			   	
               	## 2 div tags as containers to channel output into
                var channel0 = "cytoscapeweb";
                var channel1 = "note1";
                        
                var lbl1 = ${annotation};
                
                ## initialization options
                var options = {
                  	swfPath: "CytoscapeWeb",
                  	nodeTooltipsEnabled: true,
                  	edgeTooltipsEnabled: true
                };
                	 
                var vis = new org.cytoscapeweb.Visualization(channel0, options);
                    
				## callback when Cytoscape Web has finished drawing
                vis.ready(function() {
                    
					## add a listener for when nodes and edges are clicked
                    vis.addListener("click", "nodes", function(event) {
	                	handle_click(event);
	                });
    	            vis.addListener("click", "edges", function(event) {
        	        	handle_click(event);
            	    });
 


            	    #### interactive definition
            	    function handle_click(event) {
	                	var target = event.target;
	                	    
	                	clear();
                                        
                        ## print the data based on label arrays 
                        ## to specified div 
                        for (var lbl in target.data) {

                           	var value = target.data[lbl];
                        
                            ## Note: simple template only prints to one channel
                            if(fetch_lbl(lbl,lbl1)){
                             	print(lbl + " = " + value,channel1);
                            }
                        }

                        ## print content to channel (html div id)
                        function print(content,channel) {
                        	document.getElementById(channel).innerHTML += "<p.lbl>" + content + "</p.lbl></br>";
                        }
                             
                    	## determine if the label within the array is in the
                        ## passed in content
                        function fetch_lbl(content,arr_lbl){
	                       	## go though each lbl
                        	for(i=0;i<arr_lbl.length;i++){
                           		var pattern = new RegExp(arr_lbl[i]);
                           	    var is_lbl = pattern.test(content);

                           	    ## found a matching lbl
                           		if(is_lbl){
                               		break;
                               	}
                           	}
                                                        
                           	return(is_lbl);
                    	}
                        
                       	## replace printed text with nothing ("")
                      	function clear() {
                           	document.getElementById(channel1).innerHTML = "";
                        }
                    }	
                    #### end of print functions and assigning annotations 
                    #### to specific div (channels)

					#### beginning cytoscape web api implementation
                   	## add context menu item to highlight all first 
   					## neighbors of selected nodes
                   	vis.addContextMenuItem("Select first neighbors", "nodes", 
        					function (event) {
            					## Get the right-clicked node:
				        	    var rootNode = event.target;
        
            					## Get the first neighbors of that node:
            					var fneighbors = vis.firstNeighbors([rootNode]);
            					var neighborNodes = fneighbors.neighbors;
        
            					## Select the root node and its neighbors:
				        	    vis.select([rootNode]).select(neighborNodes);
        					}
					    );
				    
				    ## filter all non-selected nodes 
                   	vis.addContextMenuItem("Hide unselected nodes",
                    		"none",        
        					function (event){
        						var selected = vis.selected("nodes");
        						
	        					vis.filter("nodes", selected);
	        				
            					vis.deselect();
            					vis.zoomToFit();
            				}
					    );
				    
				    ## show all elements
                   	vis.addContextMenuItem("Show all elements",
                    		"none",        
        					function (event){
	        					vis.removeFilter();
	        					vis.zoomToFit();
	        				}
						);
					
					## select second neighbors
					vis.addContextMenuItem("Select second neighbors", "nodes", 
        					function (event) {
        					
            					## Get the right-clicked node:
				        	    var rootNode = event.target;
        						
            					## Get the first neighbors of that node:
            					var fneighbors = vis.firstNeighbors([rootNode]);
            					var firstNodes = fneighbors.neighbors;
        						        
        						## get the second neighbors
        						## array to hold all node labels
        						var sneighbors = vis.firstNeighbors(firstNodes)
        						var secondNodes = sneighbors.neighbors

				        	    vis.select(secondNodes);
        					}
					    );
				
				    ## apply a tree layout
					vis.addContextMenuItem("Apply tree layout", "none", 
        					function (event) {
        					
            					var options = { 
								     orientation: "topToBottom",
								     depthSpace: 2,
								     breadthSpace: 10,
								     subtreeSpace: 5
								};
								
								vis.layout({ name: 'Tree', options: options });
        					}
					    );
					
					## apply a circle layout
					vis.addContextMenuItem("Apply circle layout", "none", 
        					function (event) {
        					
            					var options = { 
								     angleWidth: 360
								};
								
								vis.layout({ name: 'Circle', options: options });
        					}
					    );
					    
					## apply a force-directed layout
					vis.addContextMenuItem("Apply force directed layout", "none", 
        					function (event) {
        					
            					var options = { 
								     drag:          0.2,
								     gravitation:   -1,
								     minDistance:   0,
								     maxDistance:   500,
								     mass:          10,
								     tension:       0.5,
								     weightAttr:    "id",
								     restLength:    500,
								     iterations:    200,
								     maxTime:       10000,
								     autoStabilize: false
								};
								
								vis.layout({ name: 'ForceDirected', options: options });
        					}
					    );
					    
					## expand force-directed net
					vis.addContextMenuItem("Expand network", "none", 
					    	function (event) {
					    		## update the values of desired atts
					    		var layout = vis.layout();
					    		var options = layout.options;
					    		
					    		options['mass'] = layout.options['mass'] * 2;
					    		options['autoStabilize'] = true;
					    									
								vis.layout({ name: 'ForceDirected', options: options });
        					}
					    );
					    
					## contract force-directed net
					vis.addContextMenuItem("Contract network", "none", 
					   	function (event) {
					  		## update the values of desired atts
					   		var layout = vis.layout();
					   		var options = layout.options;
					    		
					   		options['mass'] = layout.options['mass'] * 0.5;
					   		options['autoStabilize'] = true;
					    									
							vis.layout({ name: 'ForceDirected', options: options });
        				}
					);
					
					vis.addContextMenuItem("Instill config attributes", "none", 
					   	function (event) {
					   		vis.visualStyle(${style});
        				}
					);
					
				});
 				
 				## add styles and network to template
 				var net = '${network}';

				## draw it
	            var draw_options = {
        	        network: net
        	    };
                
                vis.draw(draw_options);
			};	
		</script>
	
		## html styles
		<style type="text/css">		
			body { background-color:DarkSlateBlue }                    
            #cytoscapeweb { width:1260px; height:1260px; position:absolute; left:10px; top:10px; background-color: HoneyDew; border:10px solid brown; padding:5px }
            #note1 { width:300px; height:1260px; position:absolute; left: 1350px; top:10px; background-color: HoneyDew; border:10px solid brown; padding:5px }
			#tt {position:absolute; display:block}
			#tttop {display:block; height:5px; margin-left:5px; overflow:hidden}
			#ttcont {display:block; padding:2px 12px 3px 7px; margin-left:5px; background:#666; color:#FFF}
			#ttbot {display:block; height:5px; margin-left:5px; overflow:hidden}

		</style>
	</head>

	<body>
		<div id="cytoscapeweb">
    	    Cytoscape Web will replace the contents of this div with your graph.
        </div>
        <div id="note1">Here are notes.</div>
	</body>
</html>