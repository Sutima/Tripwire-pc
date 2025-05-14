window.loadKillboard = async function(systemID, containerSelector = '#killTable tbody', maxKills = 10) {
  if (!systemID) {
    console.error('System ID is required to load the killboard.');
    return;
  } 
  
  // Clear the killboard before loading new data
  clearKillboard(containerSelector);

  // Load the killboard data


  async function getZkillData(systemID) {
    const res = await fetch(`https://zkillboard.com/api/npc/0/solarSystemID/${systemID}/kills/pastSeconds/86400/`);
    return await res.json();
  }

  async function getKillmail(killmail_id, hash) {
    const url = `https://esi.evetech.net/latest/killmails/${killmail_id}/${hash}/?datasource=tranquility`;
    const res = await fetch(url);
    return await res.json();
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
  const zkills = await getZkillData(systemID);
  const tableBody = document.querySelector(containerSelector);
  const limitedKills = zkills.slice(0, maxKills);

for (const kill of limitedKills) {
  const { killmail_id, zkb: { hash, totalValue = 0 } } = kill; 

  try {
    const killmail = await getKillmail(killmail_id, hash);

    const attacker = killmail.attackers.find(a => a.character_id && a.ship_type_id) || {};
    const victim = killmail.victim || {};

    const row = document.createElement('tr');

    const killmailDate = new Date(killmail.killmail_time);
    const formattedTime = killmailDate.toLocaleString('en-GB', {
      hour: '2-digit',
      minute: '2-digit',
      hour12: false, 
      timeZone: 'UTC'
    });
    const formattedDate = killmailDate.toLocaleString('en-GB', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      timeZone: 'UTC'
    });

    // Combine time, date, and total value into a single cell
    const timeValueCell = document.createElement('td');
    timeValueCell.innerHTML = `
      <div id="killTime">${formattedTime} UTC</div>
      <div id="killDate">${formattedDate}</div>
      <div id="killValue">${totalValue.toLocaleString()} ISK</div>
    `;
    timeValueCell.style.textAlign = 'center'; 
    row.appendChild(timeValueCell);

    // Stack victim corporation and alliance logos with links
    row.appendChild(createStackedImageCell([
      {
        url: `https://images.evetech.net/corporations/${victim.corporation_id ?? 0}/logo?tenant=tranquility&size=32`,
        link: `https://zkillboard.com/corporation/${victim.corporation_id ?? 0}`,
        className: 'corporation-logo'
      },
      {
        url: `https://images.evetech.net/alliances/${victim.alliance_id ?? 0}/logo?tenant=tranquility&size=32`,
        link: `https://zkillboard.com/alliance/${victim.alliance_id ?? 0}/`,
        className: 'alliance-logo'
      }
    ]));

    // Victim portrait with link
    row.appendChild(createImageCell(
      `https://images.evetech.net/characters/${victim.character_id ?? 0}/portrait?tenant=tranquility&size=32`,
      `https://zkillboard.com/character/${victim.character_id ?? 0}`,
      'victim-portrait' 
    ));

    // Victim ship render with link
    row.appendChild(createImageCell(
      `https://images.evetech.net/types/${victim.ship_type_id ?? 0}/render?size=64`,
      `https://zkillboard.com/kill/${killmail_id}`,
      'victim-image' 
    ));

    // Attacker ship render with link
    row.appendChild(createImageCell(
      `https://images.evetech.net/types/${attacker.ship_type_id ?? 0}/render?size=64`,
      `https://zkillboard.com/kill/${killmail_id}`,
      'attacker-image' 
    ));

    // Attacker portrait with link
    row.appendChild(createImageCell(
      `https://images.evetech.net/characters/${attacker.character_id ?? 0}/portrait?tenant=tranquility&size=32`,
      `https://zkillboard.com/character/${attacker.character_id ?? 0}`,
      'attacker-portrait' 
    ));

    // Attacker group
    row.appendChild(createStackedImageCell([
      {
        url: `https://images.evetech.net/corporations/${attacker.corporation_id ?? 0}/logo?tenant=tranquility&size=32`,
        link: `https://zkillboard.com/corporation/${attacker.corporation_id ?? 0}`
      },
      {
        url: `https://images.evetech.net/alliances/${attacker.alliance_id ?? 0}/logo?tenant=tranquility&size=32`,
        link: `https://zkillboard.com/alliance/${attacker.alliance_id ?? 0}/`
      }
    ]));



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
