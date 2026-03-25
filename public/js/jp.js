const go = new Go();
WebAssembly.instantiateStreaming(fetch("journey.wasm"), go.importObject).then((result) => {
    go.run(result.instance);

});

var startup = async function () {
    try {
        await go_refresh();
        systems = JSON.parse(await go_systems());
    } catch (error) {
        console.error(error);
        document.querySelector('.JP_loading').innerHTML = "<h4>No systems in map, refresh after adding a connection</h4>";
        return;
    }

    const zarzakhSystem = systems.find(s => s.text === "Zarzakh");

    // Custom autocomplete function because fuck materialze!
    function setupAutocomplete(inputElement, options) {
        let currentFocus;
        const autocompleteList = document.createElement("DIV");
        autocompleteList.setAttribute("id", inputElement.id + "autocomplete-list");
        autocompleteList.setAttribute("class", "autocomplete-items");
        inputElement.parentNode.appendChild(autocompleteList);

        inputElement.addEventListener("input", function (e) {
            const val = this.value;
            closeAllLists();
            if (!val) {
                return false;
            }
            currentFocus = -1;
            autocompleteList.innerHTML = '';
            autocompleteList.style.display = 'block';
            const filteredData = options.filter(system =>
                system.text != 'No System Name' && system.text.toLowerCase().indexOf(val.toLowerCase()) >= 0
            ).slice(0, 5);
            for (let i = 0; i < filteredData.length; i++) {
                const b = document.createElement("DIV");
                b.innerHTML = "<strong>" + filteredData[i].text.substr(0, val.length) + "</strong>";
                b.innerHTML += filteredData[i].text.substr(val.length);
                b.innerHTML += "<input type='hidden' value='" + filteredData[i].text + "'>";
                b.addEventListener("click", function (e) {
                    inputElement.value = this.getElementsByTagName("input")[0].value;
                    closeAllLists();
                    if (inputElement.id === 'avoidsystems-input') {
                        const system = options.find(s => s.text === inputElement.value);
                        if (system) {
                            addChip(system);
                            inputElement.value = '';
                        }
                    }
                });
                autocompleteList.appendChild(b);
            }
        });
        inputElement.addEventListener("keydown", function (e) {
            let x = document.getElementById(this.id + "autocomplete-list");
            if (x) x = x.getElementsByTagName("div");
            if (e.keyCode == 40) {
                currentFocus++;
                addActive(x);
            } else if (e.keyCode == 38) {
                currentFocus--;
                addActive(x);
            } else if (e.keyCode == 13) {
                e.preventDefault();
                if (currentFocus > -1) {
                    if (x) x[currentFocus].click();
                }
            }
        });

        function addActive(x) {
            if (!x) return false;
            removeActive(x);
            if (currentFocus >= x.length) currentFocus = 0;
            if (currentFocus < 0) currentFocus = (x.length - 1);
            x[currentFocus].classList.add("autocomplete-active");
        }

        function removeActive(x) {
            for (let i = 0; i < x.length; i++) {
                x[i].classList.remove("autocomplete-active");
            }
        }

        function closeAllLists(elmnt) {
            const x = document.getElementsByClassName("autocomplete-items");
            for (let i = 0; i < x.length; i++) {
                if (elmnt != x[i] && elmnt != inputElement) {
                    x[i].style.display = 'none'; // Hide instead of remove
                }
            }
        }

        document.addEventListener("click", function (e) {
            closeAllLists(e.target);
        });

        return {
            selectedValues: [],
            getValue: function () {
                return inputElement.value;
            },
            autocompleteList: autocompleteList
        };
    }
    // Setup autocomplete for from and to systems
    setupAutocomplete(document.getElementById("fromsystem"), systems);
    setupAutocomplete(document.getElementById("tosystem"), systems);

    // Setup chips for avoid systems nomnomnom
    const chipsInput = document.getElementById('avoidsystems-input');
    const chipsContainer = document.getElementById('avoidsystems-chips');

    setupAutocomplete(chipsInput, systems);

    chipsInput.addEventListener('keydown', function (e) {
        if (e.key === 'Enter') {
            e.preventDefault();
            const value = this.value.trim();
            const system = systems.find(s => s.text.toLowerCase() === value.toLowerCase());
            if (system) {
                addChip(system);
                this.value = '';
            }
        }
    });

    function addChip(system) {
        if (Array.from(chipsContainer.children).some(chip => chip.dataset.id === system.id.toString())) {
            return;
        }
        const chip = document.createElement('div');
        chip.className = 'chip';
        chip.textContent = system.text;
        chip.dataset.id = system.id;
        const closeBtn = document.createElement('span');
        closeBtn.className = 'closebtn';
        closeBtn.innerHTML = '&times;';
        closeBtn.onclick = function () {
            chip.remove();
        };
        chip.appendChild(closeBtn);
        chipsContainer.appendChild(chip);
    }
    // When setting up the autocomplete for avoid systems
    const avoidSystemsAutocomplete = setupAutocomplete(chipsInput, systems);

    // Add click event listener to the autocomplete list
    avoidSystemsAutocomplete.autocompleteList.addEventListener('click', function (e) {
        if (e.target && e.target.nodeName === 'DIV') {
            const systemName = e.target.getElementsByTagName('input')[0].value;
            const system = systems.find(s => s.text === systemName);
            if (system) {
                addChip(system);
                chipsInput.value = '';
            }
        }
    });

    $('#loading').css('display', 'none');
    $('#loaded').css('display', 'block');

    $("#JP_calculate").click(async function () {
        let fromsystem = document.getElementById("fromsystem");
        let tosystem = document.getElementById("tosystem");
        let avoidsystems = Array.from(chipsContainer.children).map(chip => chip.textContent);

        if (fromsystem.value === "") {
            alert('You must select a from system');
            return;
        }

        if (tosystem.value === "") {
            alert('You must select a to system');
            return;
        }

        // Find the full system objects
        let fromSystemObj = systems.find(s => s.text === fromsystem.value);
        let toSystemObj = systems.find(s => s.text === tosystem.value);

        if (!fromSystemObj || !toSystemObj) {
            alert('Invalid system selected');
            return;
        }


        // Get chips and other snacks from the UI
        let avoidList = Array.from(chipsContainer.children).map(chip => ({
            id: parseInt(chip.dataset.id, 10),
            text: chip.textContent.replace('×', '').trim()
        }));

        // Toggle Zarzakh avoidance based on the checkbox
        if ($('#avoidzarzakh').prop('checked') && zarzakhSystem && !avoidList.some(s => s.text === "Zarzakh")) {
            avoidList.push({
                id: zarzakhSystem.id,
                text: zarzakhSystem.text
            });
        }

        var options = {
            fromsystem: fromSystemObj,
            tosystem: toSystemObj,
            avoidsystems: avoidList,
            shipsize: parseInt($('#shipsize').find(":selected").val()),
            excludevoc: $('#excludevoc').prop('checked'),
            excludeeol: $('#excludeeol').prop('checked'),
            excludelowsec: $('#excludelowsec').prop('checked'),
            excludenullsec: $('#excludenullsec').prop('checked'),
            excludethera: $('#excludethera').prop('checked')
        };

        try {
            navigation = JSON.parse(await go_navigate(JSON.stringify(options)));
        } catch (error) {
            alert(error);
            return;
        }

        var systemlist = [];
        var routestring = "";
        var lastsignature = "";
        var lastsystem = "";

        $('#result').empty();
        navigation.forEach(function (entry) {
            var securityclass = "nullsec";
            if (entry.node.security >= 0.45) {
                securityclass = "hisec";
            } else if (entry.node.security < 0.45 && entry.node.security > 0) {
                securityclass = "lowsec";
            }
            var lifeclass = "";
            if (entry.edge.lifestatus == "critical") {
                lifeclass = "critical"
            }
            var massclass = "";
            if (entry.edge.massstatus == "critical") {
                massclass = "critical"
            } else if (entry.edge.massstatus == "destab") {
                massclass = "destab"
            }
            if (entry.node.name == "Thera") {
                entry.node.class = "";
            }
            if (entry.edge.lifestatus == "critical") {
                entry.edge.lifestatus = "end of life";
            }
            $('#result').append(
                "<tr>" +
                "<td><a href='https://zkillboard.com/system/" + entry.node.systemid + "/' target='_blank'>" + entry.node.name + "</a></td>" +
                "<td class='" + securityclass + "'>" + entry.node.security + "</td>" +
                "<td>" + entry.node.class + "</td>" +
                "<td>" + entry.edge.signature + "</td>" +
                "<td class='" + lifeclass + "'>" + entry.edge.lifestatus + "</td>" +
                "<td class='" + massclass + "'>" + entry.edge.massstatus + "</td>" +
                "<td>" + entry.edge.jumpmass + "</td>" +
                "<td id='kills-" + entry.node.systemid + "'></td>" +
                "</tr>");

            systemlist.push(entry.node.systemid);

            if (entry.edge.signature != '') {
                if (lastsystem != '' && lastsignature == '') {
                    routestring += ' > ' + lastsystem;
                }
                routestring += " > " + entry.edge.signature;
                if (entry.node.name == 'Thera') {
                    routestring += ' (Thera)';
                }
            }
            lastsystem = entry.node.name;
            lastsignature = entry.edge.signature;
        });

        routestring += " > " + lastsystem;
        $('#pastable').val(routestring);

        $('#jumps').html(systemlist.length);

        const url = 'https://corsproxy.io/?' + encodeURIComponent('https://eve-gatecheck.space/eve/get_kills.php?systems=' + systemlist.join(','));
        $.getJSON(url, function (data) {
            systemlist.forEach(function (systemid) {
                if (typeof (data[systemid]) !== "undefined") {
                    $('#kills-' + systemid).html(data[systemid].kills.killCount + " (" + data[systemid].kills.gateKillCount + " on gate)");
                    $('#kills-' + systemid).addClass('red').addClass('darken-4');
                }
            });
        });
    });

    $("#JP_refresh").click(async function () {
        $(".btn").addClass('disabled');
        try {
            await go_refresh();
        } catch (error) {
            alert(error);
        }
        $(".btn").removeClass('disabled');
    });
};