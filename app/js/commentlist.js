const commentCache = new Map();
const commentCACHE_DURATION = 60 * 1000; 
bustCache = function (name) {
    name.data = null;
    name.timestamp = 0;
    console.log("Cache busted");
};
commentData = function() {
    const now = Date.now();
    if (commentCache.data && (now - commentCache.timestamp < commentCACHE_DURATION)) {
        // Use cached data
        return Promise.resolve(filterComments(commentCache.data));
    }
    return $.ajax({
        url: "commentlist.php",
        type: "GET",
        dataType: "JSON",
    }).then(function(data) {
        commentCache.data = data;
        commentCache.timestamp = Date.now();
        return filterComments(data);
    }).fail(function(jqXHR, textStatus, errorThrown) {
        console.error("AJAX request failed: " + textStatus, errorThrown);
        return [];
    });
};


function filterComments(data) {
    // Get the current chain system IDs
    const currentChainIDs = collectSystemIDs();

    // Filter the comments to only include those in the current chain
    const matchingComments = data.commentlist.commentlist.filter(comment => 
        currentChainIDs.includes(comment.systemID.toString())
    );

    // Apply the matching comments to the chain map

    $("#chainMap div.node").removeClass("commentNode");
    matchingComments.forEach(comment => {
        $("#chainMap [data-nodeid='" + comment.systemID + "']").addClass("commentNode");
    });

    return matchingComments;
};

collectSystemIDs = function() {
    const currentChain = [];
    const nodes = document.querySelectorAll('#chainMap [data-nodeid]');
    
    nodes.forEach(node => {
        const systemID = node.getAttribute('data-nodeid');
        if (systemID && !currentChain.includes(systemID)) {
            currentChain.push(systemID);
        }
    });

    return currentChain;
};