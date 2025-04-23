/*

signatures[add][0][wormhole][type]: GATE
signatures[add][0][wormhole][parent]: initial
signatures[add][0][wormhole][life]: stable
signatures[add][0][wormhole][mass]: stable
signatures[add][0][signatures][0][signatureID]: gat
signatures[add][0][signatures][0][systemID]: 30000142
signatures[add][0][signatures][0][type]: wormhole
signatures[add][0][signatures][0][name]: 
signatures[add][0][signatures][0][lifeLength]: 259200
signatures[add][0][signatures][1][signatureID]: gat
signatures[add][0][signatures][1][systemID]: 30000143
signatures[add][0][signatures][1][type]: wormhole
signatures[add][0][signatures][1][name]: 
signatures[add][0][signatures][1][lifeLength]: 259200


                var signature = $.map(tripwire.client.signatures, function(signature) { if (signature.signatureID && signature.signatureID.toUpperCase().startsWith(bookmark.sigShort.toUpperCase()) && signature.systemID == viewingSystemID) return signature; })[0];
                if(!signature) continue;
                var wormhole = $.map(tripwire.client.wormholes, function(wormhole) { if (wormhole.initialID == signature.id || wormhole.secondaryID == signature.id) return wormhole; })[0] || {};
                var otherSignature = (signature.id == wormhole.initialID ? tripwire.client.signatures[wormhole.secondaryID] : tripwire.client.signatures[wormhole.initialID]) || {};

*/

function signaturePairsForSystem(systemID) {
    return $.map(tripwire.client.signatures, function(signature) {
        if (signature.systemID != systemID) return;
        var wormhole = $.map(tripwire.client.wormholes, function(wormhole) { if (wormhole.initialID == signature.id || wormhole.secondaryID == signature.id) return wormhole; })[0];
        var otherSignature = (signature.id == wormhole.initialID ? tripwire.client.signatures[wormhole.secondaryID] : tripwire.client.signatures[wormhole.initialID]);
        var otherSystemID = otherSignature.systemID;
        console.log('signature', signature);
        return { otherSystemID, signature, wormhole, otherSignature };
    });
}

tripwire.addGatesForCurrentSystem = function() {
    if(tripwire.isRefreshing) return;
    const connections = guidance.connections(tripwire.map.shortest, viewingSystemID);
    if(!connections.length) return;
    const pairs = signaturePairsForSystem(viewingSystemID);

    var payload = {"signatures": {"add": [], "update": []}, "systemID": viewingSystemID};
    var undo = [];

    connections.map(c => {
        const system = systemAnalysis.analyse(c.systemID);
        if (c.closed) return;
        var pair = $.map(pairs, function(pair) { if (pair.otherSystemID == c.systemID) return pair; })[0];
        if (pair) return;
        payload.signatures.add.push({
            "wormhole": {
                "type": "GATE",
                "parent": "initial",
                "life": "stable",
                "mass": "stable"
            },
            "signatures": [
                {
                    "signatureID": "gat",
                    "systemID": viewingSystemID,
                    "type": "wormhole",
                    "lifeLength": options.signatures.pasteLife * 60 * 60
                },
                {
                    "signatureID": "gat",
                    "systemID": c.systemID,
                    "type": "wormhole",
                    "lifeLength": options.signatures.pasteLife * 60 * 60
                }
            ]
        });
    });

    if (payload.signatures.add.length || payload.signatures.update.length) {
        var success = function(data) {
            if (data.resultSet && data.resultSet[0].result == true) {
                $("#undo").removeClass("disabled");

                if (data.results) {
                    if (viewingSystemID in tripwire.signatures.undo) {
                        tripwire.signatures.undo[viewingSystemID].push({action: "add", signatures: data.results});
                    } else {
                        tripwire.signatures.undo[viewingSystemID] = [{action: "add", signatures: data.results}];
                    }
                }

                if (undo.length) {
                    if (viewingSystemID in tripwire.signatures.undo) {
                        tripwire.signatures.undo[viewingSystemID].push({action: "update", signatures: undo});
                    } else {
                        tripwire.signatures.undo[viewingSystemID] = [{action: "update", signatures: undo}];
                    }
                }

                sessionStorage.setItem("tripwire_undo", JSON.stringify(tripwire.signatures.undo));
            }
        }

        var always = function(data) { tripwire.isRefreshing = false; }
        tripwire.refresh('refresh', payload, success, always);
    } else {
        tripwire.isRefreshing = false;
    }
}

