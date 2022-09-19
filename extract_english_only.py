import spacy_fastlang
import spacy

#@Language.factory("language_detector")
#def get_lang_detector(nlp, name):
#   return LanguageDetector()

nlp = spacy.load("en_core_web_sm")
#nlp.add_pipe('language_detector', last=True)

doc = nlp("This is an text. That references the island of Corsica and Homer Simpson.")
print(doc.lang_)
print(doc.ents)
#doc.lang
