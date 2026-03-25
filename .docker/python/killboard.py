import requests
import time
import os
import logging
from datetime import datetime
from sqlalchemy import create_engine, Column, Integer, String, DateTime, Boolean, Float, func
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

Base = declarative_base()

db_host = os.getenv('DB_HOST')
db_name = os.getenv('DB_NAME')
db_user = os.getenv('DB_USER')
db_password = os.getenv('DB_PASSWORD')

engine = create_engine(f'mysql://{db_user}:{db_password}@{db_host}/{db_name}')
Session = sessionmaker(bind=engine)

class Killmail(Base):
    __tablename__ = 'killmails'

    killmail_id = Column(Integer, primary_key=True)
    sequence_id = Column(Integer)
    killmail_hash = Column(String(255))
    killmail_time = Column(DateTime)
    solar_system_id = Column(Integer)
    npc = Column(Boolean)
    total_value = Column(Float)
    victim_id = Column(Integer)
    victim_ship = Column(Integer)
    victim_corp = Column(Integer)
    victim_alliance = Column(Integer)
    attacker_id = Column(Integer)
    attacker_corp = Column(Integer)
    attacker_alliance = Column(Integer)
    attacker_faction = Column(Integer)
    attacker_ship = Column(Integer)
    total_attackers = Column(Integer)
    uploaded_at = Column(Integer)
    sequence_updated = Column(Integer, nullable=True)

def get_sequence():
    # Fetch the current sequence number from zkill's sequence endpoint
    try:
        response = requests.get('https://r2z2.zkillboard.com/ephemeral/sequence.json')
        response.raise_for_status()
        data = response.json()
        return data.get('sequence')
    except requests.RequestException as e:
        logging.error(f"Error fetching sequence from sequence.json: {e}")
        return None

def get_killmail(sequence_id):
    url = f'https://r2z2.zkillboard.com/ephemeral/{sequence_id}.json'
    try:
        response = requests.get(url)
        if response.status_code == 404:
            return None
        response.raise_for_status()
        return response.json()
    except requests.RequestException as e:
        if response.status_code == 429:
            logging.warning("Rate limit exceeded. Waiting before retrying...")
        else:
            logging.error(f"Error fetching from R2Z2: {e}")
        return None

def process_kill(killmail_data):
    session = Session()
    try:
        killmail_id = killmail_data.get('killmail_id')
        killmail_hash = killmail_data.get('hash')
        esi_data = killmail_data.get('esi', {})
        zkb_data = killmail_data.get('zkb', {})
        uploaded_at = killmail_data.get('uploaded_at')
        sequence_id = killmail_data.get('sequence_id')
        sequence_updated = killmail_data.get('sequence_updated')
        
        # Extract victim data
        victim = esi_data.get('victim', {})
        
        # Extract attackers data
        attackers = esi_data.get('attackers', [])
        
        # Find the attacker who dealt the final blow
        final_blow_attacker = next((a for a in attackers if a.get('final_blow') == True), None)
        
        # Parse the killmail_time
        killmail_time = datetime.strptime(esi_data.get('killmail_time', ''), '%Y-%m-%dT%H:%M:%SZ')
        
        killmail_obj = Killmail(
            killmail_id=killmail_id,
            sequence_id=sequence_id,
            killmail_hash=killmail_hash,
            killmail_time=killmail_time,
            solar_system_id=esi_data.get('solar_system_id'),
            npc=zkb_data.get('npc', False),
            total_value=zkb_data.get('totalValue', 0),
            victim_id=victim.get('character_id'),
            victim_ship=victim.get('ship_type_id'),
            victim_corp=victim.get('corporation_id'),
            victim_alliance=victim.get('alliance_id'),
            attacker_id=final_blow_attacker.get('character_id') if final_blow_attacker else None,
            attacker_corp=final_blow_attacker.get('corporation_id') if final_blow_attacker else None,
            attacker_alliance=final_blow_attacker.get('alliance_id') if final_blow_attacker else None,
            attacker_faction=final_blow_attacker.get('faction_id') if final_blow_attacker else None,
            attacker_ship=final_blow_attacker.get('ship_type_id') if final_blow_attacker else None,
            total_attackers=len(attackers),
            uploaded_at=uploaded_at,
            sequence_updated=sequence_updated
        )
        session.merge(killmail_obj)
        session.commit()
        logging.info(f"Processed killmail sequence_id: {sequence_id}, killmail_id: {killmail_id}")
    except Exception as e:
        logging.error(f"Error processing killmail: {e}")
        session.rollback()
    finally:
        session.close()

def get_last_sequence_from_db():
    # Fetch the maximum sequence_id from the database and start there.
    session = Session()
    try:
        result = session.query(func.max(Killmail.sequence_id)).scalar()
        return result
    except Exception as e:
        logging.error(f"Error fetching last sequence from DB: {e}")
        return None
    finally:
        session.close()

def main():
    logging.info("Starting killboard processing")
    
    # Start last sequence from database if available
    last_sequence = get_last_sequence_from_db()
    
    if last_sequence:
        sequence = last_sequence + 1
        logging.info(f"Found last sequence in DB: {last_sequence}, starting from {sequence}")
    else:
        sequence = get_sequence()
        if sequence is None:
            logging.error("Failed to get starting sequence. Exiting.")
            return
        logging.info(f"No data in DB, starting from current sequence: {sequence}")
    
    while True:
        killmail_data = get_killmail(sequence)
        
        if killmail_data:
            process_kill(killmail_data)
            sequence += 1
            time.sleep(0.1)
        else:
            logging.info(f"No killmail at sequence {sequence}, waiting 10 seconds...")
            time.sleep(10)

if __name__ == '__main__':
    main()
