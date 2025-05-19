import requests
import time
import os
import logging
from datetime import datetime
from sqlalchemy import create_engine, Column, Integer, String, DateTime, Boolean, Float
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

Base = declarative_base()

db_host = os.getenv('DB_HOST')
db_name = os.getenv('DB_NAME')
db_user = os.getenv('DB_USER')
db_password = os.getenv('DB_PASSWORD')
queue_id = os.getenv('REDISQ_QUEUE_ID')

engine = create_engine(f'mysql://{db_user}:{db_password}@{db_host}/{db_name}')
Session = sessionmaker(bind=engine)

class Killmail(Base):
    __tablename__ = 'killmails'
    
    killmail_id = Column(Integer, primary_key=True)
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

def get_kill_from_redisq():
    url = f'https://redisq.zkillboard.com/listen.php?queueID={queue_id}'
    try:
        response = requests.get(url)
        response.raise_for_status()
        return response.json()
    except requests.RequestException as e:
        logging.error(f"Error fetching from RedisQ: {e}")
        return None

def process_kill(kill):
    session = Session()
    try:
        package = kill['package']
        killmail = package['killmail']
        zkb = package['zkb']
        victim = killmail['victim']
        
        # Find the attacker who dealt the final blow
        final_blow_attacker = next((a for a in killmail['attackers'] if a.get('final_blow') == True), None)

        # Parse the killmail_time
        killmail_time = datetime.strptime(killmail['killmail_time'], '%Y-%m-%dT%H:%M:%SZ')


        killmail_obj = Killmail(
            killmail_id=package['killID'],
            killmail_hash=zkb['hash'],
            killmail_time=killmail_time,  
            solar_system_id=killmail['solar_system_id'],
            npc=zkb['npc'],
            total_value=zkb['totalValue'],
            victim_id=victim['character_id'],
            victim_ship=victim['ship_type_id'],
            victim_corp=victim['corporation_id'],
            victim_alliance=victim.get('alliance_id'),
            attacker_id=final_blow_attacker.get('character_id') if final_blow_attacker else None,
            attacker_corp=final_blow_attacker.get('corporation_id') if final_blow_attacker else None,
            attacker_alliance=final_blow_attacker.get('alliance_id') if final_blow_attacker else None,
            attacker_faction=final_blow_attacker.get('faction_id') if final_blow_attacker else None,
            attacker_ship=final_blow_attacker.get('ship_type_id') if final_blow_attacker else None,
            total_attackers=len(killmail['attackers'])
        )
        session.merge(killmail_obj)
        session.commit()
        # logging.info(f"Processed killmail {killmail_obj.killmail_id}")
    except Exception as e:
        logging.error(f"Error processing kill: {e}") 
        session.rollback()
    finally:
        session.close()

def main():
    logging.info("Starting killboard processing")
    while True:
        kill = get_kill_from_redisq()
        if kill and 'package' in kill:
            process_kill(kill)
        else:
            time.sleep(0.1)  

if __name__ == '__main__':
    main()