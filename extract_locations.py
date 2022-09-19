import spacy
import spacy_fastlang
from spacy import displacy
import os
import json
import csv

path = "./brewery_info_json"

nlp = spacy.load('en_core_web_sm')
#nlp.add_pipe("language_detector")

export = []

with open('output.csv', 'w', newline='', encoding="utf-8") as csvfile:
    fieldnames = ['brewery_id', 'brewery_name', 'country_name', 'brewery_in_production', 'is_independent', 'beer_count', 
    'brewery_type', 'brewery_type_id', 'brewery_address', 'brewery_city', 'brewery_state', 'brewery_lat', 'brewery_lng',
    'brewery_rating_count', 'brewery_rating_score', 'brewery_age_on_service', 'TOTAL_ENTITIES', 'CARDINAL', 'DATE', 'EVENT',
    'FAC', 'GPE', 'LANGUAGE', 'LAW', 'LOC', 'MONEY', 'NORP', 'ORDINAL', 'ORG', 'PERCENT', 'PERSON', 'PRODUCT', 'QUANTITY', 
    'TIME', 'WORK_OF_ART']
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    writer.writeheader()

    # use scandir here as it's gonna get big....
    for entry in os.scandir(path):
        if not entry.name.startswith('.') and entry.is_file():

                output = {}

            # breaking here even tho entry.path is a str...
            # need the 'rb' option to read the file as binary.
                with open(entry.path, 'rb') as f:
                    d = json.load(f)

                    doc = nlp(d['brewery_description'])

                    # only process English docs
                    if (doc.lang_ == 'en'):

                        # load up dictionary with interesting stuff...
                        output['brewery_id'] = d['brewery_id']
                        output['brewery_name'] = d['brewery_name']
                        output['country_name'] = d['country_name']
                        output['brewery_in_production'] = d['brewery_in_production']
                        output['is_independent'] = d['is_independent']
                        output['beer_count'] = d['beer_count']
                        output['brewery_type'] = d['brewery_type']
                        output['brewery_type_id'] = d['brewery_type_id']
                        output['brewery_address'] = d['location']['brewery_address']
                        output['brewery_city'] = d['location']['brewery_city']
                        output['brewery_state'] = d['location']['brewery_state']
                        output['brewery_lat'] = d['location']['brewery_lat']
                        output['brewery_lng'] = d['location']['brewery_lng']
                        output['brewery_rating_count'] = d['rating']['count']
                        output['brewery_rating_score'] = d['rating']['rating_score']
                        output['brewery_age_on_service'] = d['stats']['age_on_service']
                        output['TOTAL_ENTITIES'] = len(doc.ents)

                        for lab in nlp.get_pipe('ner').labels: #FYI - had to change this for spacy 3
                            output[lab] = len([ent for ent in doc.ents if ent.label_ == lab])
                        print(output)
                        writer.writerow(output)


#displacy.serve(doc, style = "ent")