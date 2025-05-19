let loadedKills = 0;
let allKills = [];
let systemID;
window.loadKillboard = async function(newSystemID, containerSelector = '#killTable tbody', killsToLoad = 10) {
  if (newSystemID) {
    systemID = newSystemID;
    loadedKills = 0;
    allKills = [];
  }

  if (!systemID) {
    console.error('System ID is required to load the killboard.');
    return;
  } 

  if (loadedKills === 0) {
    clearKillboard(containerSelector);
    allKills = await getZkillData(systemID);
  }

  const tableBody = document.querySelector(containerSelector);
  const ignoreNPCKills = document.getElementById('ignoreNPCKills').checked;

  let killsToShow = allKills.kills.slice(loadedKills);
  if (ignoreNPCKills) {
    killsToShow = killsToShow.filter(kill => kill.npc !== 1);
  }
  killsToShow = killsToShow.slice(0, killsToLoad);

  for (const kill of killsToShow) {
    try {
    // Create a row for time and value
    const timeValueRow = document.createElement('tr');
    timeValueRow.className = 'time-value-row';
    timeValueRow.setAttribute('data-killmail-id', kill.killmail_id);

    // Create and populate the time and value cell
    const timeValueCell = document.createElement('td');
    timeValueCell.colSpan = 7; // Span across all columns

    const killTime = new Date(kill.killmail_time);
    const formattedTime = killTime.toLocaleString('en-GB', {
      hour: '2-digit',
      minute: '2-digit',
      hour12: false, 
      timeZone: 'UTC'
    });
    const formattedDate = killTime.toLocaleString('en-GB', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      timeZone: 'UTC'
    });


    timeValueCell.innerHTML = `
      <div class="time-value-container">
        <span class="kill-time">${formattedTime} UTC</span>
        <span class="kill-date">${formattedDate}</span>
        <span class="kill-value">${Number(kill.total_value).toLocaleString()} ISK</span>
      </div>
    `;
    timeValueRow.appendChild(timeValueCell);

    // Add the time-value row to the table
    tableBody.appendChild(timeValueRow);
      const row = document.createElement('tr');
      row.className = 'kill-row';
      row.setAttribute('data-killmail-id', kill.killmail_id);
    
      // Victim corporation and alliance
      const victimImageUrls = [{
        url: `https://images.evetech.net/corporations/${kill.victim_corp}/logo?tenant=tranquility&size=32`,
        link: `https://zkillboard.com/corporation/${kill.victim_corp}`,
        className: 'corporation-logo'
      }];

      if (kill.victim_alliance && kill.victim_alliance !== '0') {
        victimImageUrls.push({
          url: `https://images.evetech.net/alliances/${kill.victim_alliance}/logo?tenant=tranquility&size=32`,
          link: `https://zkillboard.com/alliance/${kill.victim_alliance}/`,
          className: 'alliance-logo'
        });
      }

      row.appendChild(createStackedImageCell(victimImageUrls));

      // Victim portrait
      row.appendChild(createImageCell(
        `https://images.evetech.net/characters/${kill.victim_id}/portrait?tenant=tranquility&size=32`,
        `https://zkillboard.com/character/${kill.victim_id}`,
        'victim-portrait' 
      ));

      // Victim ship
      row.appendChild(createImageCell(
        `https://images.evetech.net/types/${kill.victim_ship}/render?size=64`,
        `https://zkillboard.com/kill/${kill.killmail_id}`,
        'victim-image' 
      ));

        // Attacker ship
      const attackerShipCell = createImageCell(
        `https://images.evetech.net/types/${kill.attacker_ship}/render?size=64`,
        `https://zkillboard.com/kill/${kill.killmail_id}`,
        `attacker-image`
      );

      // Add a label for total attackers
      if (kill.npc === 1) {
        const label = document.createElement('div');
        label.className = 'attacker-count npc';
        label.textContent = 'NPC';
        attackerShipCell.querySelector('.image-container').appendChild(label);
      }
      else if (kill.total_attackers == 1) {
        const label = document.createElement('div');
        label.className = 'attacker-count solo';
        label.textContent = 'Solo';
        attackerShipCell.querySelector('.image-container').appendChild(label);
      } else {
        const label = document.createElement('div');
        label.className = 'attacker-count';
        label.textContent = kill.total_attackers;
        attackerShipCell.querySelector('.image-container').appendChild(label);
      }

      row.appendChild(attackerShipCell);

      // Attacker portrait
      row.appendChild(createImageCell(
        `https://images.evetech.net/characters/${kill.attacker_id}/portrait?tenant=tranquility&size=32`,
        `https://zkillboard.com/character/${kill.attacker_id}`,
        'attacker-portrait' 
      ));

      // Attacker corporation and alliance
      
      const attackerImageUrls = [{
        url: `https://images.evetech.net/corporations/${kill.attacker_corp}/logo?tenant=tranquility&size=32`,
        link: `https://zkillboard.com/corporation/${kill.attacker_corp}`,
        className: 'corporation-logo'
      }];

      if (kill.attacker_alliance && kill.attacker_alliance !== '0') {
        attackerImageUrls.push({
          url: `https://images.evetech.net/alliances/${kill.attacker_alliance}/logo?tenant=tranquility&size=32`,
          link: `https://zkillboard.com/alliance/${kill.attacker_alliance}/`,
          className: 'alliance-logo'
        });
      }

      row.appendChild(createStackedImageCell(attackerImageUrls));

      tableBody.appendChild(row);


      
      // // Add kill tiem and value 
      // const killTime = new Date(kill.killmail_time);
      // const formattedTime = killTime.toLocaleString('en-GB', {
      //   hour: '2-digit',
      //   minute: '2-digit',
      //   hour12: false, 
      //   timeZone: 'UTC'
      // });
      // const formattedDate = killTime.toLocaleString('en-GB', {
      //   day: '2-digit',
      //   month: '2-digit',
      //   year: 'numeric',
      //   timeZone: 'UTC'
      // });

      // const timeValueCell = document.createElement('td');
      // timeValueCell.innerHTML = `<div id='timeValue'>
      //   <div id="killTime">${formattedTime} UTC</div>
      //   <div id="killDate">${formattedDate}</div>
      //   <div id="killValue">${Number(kill.total_value).toLocaleString()} ISK</div></div>
      // `;
      // timeValueCell.style.textAlign = 'center'; 
      // row.appendChild(timeValueCell);

    } catch (err) {
      console.warn(`Failed to process killmail:`, err);
    }
  }

  loadedKills += killsToShow.length;

  // Update the "load more" button when all kills have been loaded
  const loadMoreButton = document.getElementById('loadMoreKills');
  if (loadMoreButton) {
    const remainingKills = ignoreNPCKills 
      ? allKills.kills.filter(kill => kill.npc !== 1).length - loadedKills
      : allKills.kills.length - loadedKills;

    loadMoreButton.textContent = remainingKills <= 0 ? 'All Kills Loaded!' : 'Load More!';
    loadMoreButton.disabled = remainingKills <= 0;
  }
};

async function getZkillData(systemID) {
  try {
    const res = await fetch(`/killboard.php?systemID=${systemID}`);
    if (!res.ok) {
      throw new Error(`HTTP error! status: ${res.status}`);
    }
    const data = await res.json();
    if (data.error) {
      throw new Error(data.error);
    }
    return data;
  } catch (error) {
    console.error('Error fetching killboard data:', error);
    return [];
  }
}
//single cell
function createImageCell(url, link = null, classNames = null) {
  const td = document.createElement('td');
  const container = document.createElement('div');
  container.classList.add('image-container');

  if (classNames) {
    classNames.split(' ').forEach(className => {
      container.classList.add(className);
    });
  }

  const img = document.createElement('img');
  img.src = url;

  if (link) {
    const a = document.createElement('a');
    a.href = link;
    a.target = '_blank'; 
    a.appendChild(img);
    container.appendChild(a);
  } else {
    container.appendChild(img);
  }

  td.appendChild(container);
  return td;
}
// Corp and alliance logo stacking
function createStackedImageCell(urlsAndLinks) {
  const td = document.createElement('td');
  const container = document.createElement('div');
  container.classList.add('image-container');
  container.style.display = 'flex';
  container.style.flexDirection = 'column';
  container.style.alignItems = 'center';

  urlsAndLinks.forEach(({ url, link, className }) => {
    const imgContainer = document.createElement('div');
    imgContainer.classList.add('image-container');
    if (className) {
      imgContainer.classList.add(className);
    }

    const img = document.createElement('img');
    img.src = url;

    if (link) {
      const a = document.createElement('a');
      a.href = link;
      a.target = '_blank'; 
      a.appendChild(img);
      imgContainer.appendChild(a);
    } else {
      imgContainer.appendChild(img);
    }

    container.appendChild(imgContainer);
  });

  td.appendChild(container);
  return td;
}

window.clearKillboard = function(containerSelector = '#killTable tbody') {
  const tableBody = document.querySelector(containerSelector);
  if (tableBody) tableBody.innerHTML = '';
  loadedKills = 0;
  allKills = [];
};
// Modify the DOMContentLoaded event listener
window.addEventListener('DOMContentLoaded', () => {
  const loadMoreButton = document.getElementById('loadMoreKills');
  if (loadMoreButton) {
    loadMoreButton.addEventListener('click', () => {
      loadKillboard(null, '#killTable tbody', 10);
    });
  }

  const ignoreNPCKillsCheckbox = document.getElementById('ignoreNPCKills');
  if (ignoreNPCKillsCheckbox) {
    ignoreNPCKillsCheckbox.addEventListener('change', () => {
      loadedKills = 0; 
      loadKillboard(systemID);
    });
  }
});

//initialize 
window.initializeKillboard = function(initialSystemID) {
  systemID = initialSystemID;
  loadedKills = 0;
  allKills = [];
  loadKillboard(systemID);
};