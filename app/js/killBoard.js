window.loadKillboard = async function(systemID, containerSelector = '#killTable tbody', maxKills = 10) {
  if (!systemID) {
    console.error('System ID is required to load the killboard.');
    return;
  } 
  
  // Clear the killboard before loading new data
  clearKillboard(containerSelector);

  // Load the killboard data


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

  function createImageCell(url, link = null, className = null) {
    const td = document.createElement('td');
    const container = document.createElement('div');
    container.classList.add('image-container');

    if (className) {
      container.classList.add(className);
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
  const kills = await getZkillData(systemID);
  const tableBody = document.querySelector(containerSelector);
  const limitedKills = kills.kills.slice(0, maxKills);

  for (const kill of limitedKills) {
    try {
      const row = document.createElement('tr');

      // Process time and value
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

      const timeValueCell = document.createElement('td');
      timeValueCell.innerHTML = `
        <div id="killTime">${formattedTime} UTC</div>
        <div id="killDate">${formattedDate}</div>
        <div id="killValue">${Number(kill.total_value).toLocaleString()} ISK</div>
      `;
      timeValueCell.style.textAlign = 'center'; 
      row.appendChild(timeValueCell);

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
      row.appendChild(createImageCell(
        `https://images.evetech.net/types/${kill.attacker_ship}/render?size=64`,
        `https://zkillboard.com/kill/${kill.killmail_id}`,
        'attacker-image' 
      ));

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
  } catch (err) {
    console.warn(`Failed to fetch killmail ${killmail_id}:`, err);
  }
}
};


window.clearKillboard = function(containerSelector = '#killTable tbody') {
  const tableBody = document.querySelector(containerSelector);
  if (tableBody) tableBody.innerHTML = '';
};



// initialize the killboard 
window.addEventListener('DOMContentLoaded', () => {
  loadKillboard();
});
