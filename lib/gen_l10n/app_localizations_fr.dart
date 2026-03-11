// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'SOLMA';

  @override
  String get welcomeBack => 'Bon retour';

  @override
  String get signInSubtitle => 'Connectez-vous pour continuer sur SOLMA';

  @override
  String get email => 'E-mail';

  @override
  String get emailHint => 'votre@email.com';

  @override
  String get emailRequired => 'E-mail requis';

  @override
  String get emailInvalid => 'E-mail invalide';

  @override
  String get password => 'Mot de passe';

  @override
  String get passwordRequired => 'Mot de passe requis';

  @override
  String get passwordMinLength => 'Min. 6 caractères';

  @override
  String get signIn => 'Connexion';

  @override
  String get dontHaveAccount => 'Pas encore de compte ? ';

  @override
  String get signUp => 'Inscription';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get joinSubtitle =>
      'Rejoignez SOLMA pour la meilleure expérience chaussures';

  @override
  String get fullName => 'Nom complet';

  @override
  String get fullNameHint => 'Jean Dupont';

  @override
  String get nameRequired => 'Nom requis';

  @override
  String get alreadyHaveAccount => 'Déjà un compte ? ';

  @override
  String errorPrefix(String message) {
    return 'Erreur : $message';
  }

  @override
  String get navHome => 'Accueil';

  @override
  String get navSearch => 'Recherche';

  @override
  String get navCart => 'Panier';

  @override
  String get navProfile => 'Profil';

  @override
  String get bestSale => 'Meilleure vente';

  @override
  String get bestChoice => 'Meilleur choix';

  @override
  String get discount => 'Réduction';

  @override
  String get upTo => 'Jusqu\'à ';

  @override
  String get shopNow => 'Acheter';

  @override
  String get categoryAll => 'Tout';

  @override
  String get categoryMen => 'Hommes';

  @override
  String get categoryWomen => 'Femmes';

  @override
  String get categoryKids => 'Enfants';

  @override
  String get sectionPopular => 'Populaire';

  @override
  String get sectionNewArrivals => 'Publicité';

  @override
  String get sectionNew => 'Nouveautés';

  @override
  String get sectionTenuesAfricaines => 'Tenues Africaines';

  @override
  String get sectionSacsAMain => 'Sacs à Main';

  @override
  String get sectionSports => 'Sport';

  @override
  String get seeAll => 'Tout voir';

  @override
  String get loadingProducts => 'Chargement des produits…';

  @override
  String get loading => 'Chargement…';

  @override
  String get loadError => 'Erreur de chargement.';

  @override
  String get retry => 'Réessayer';

  @override
  String get errorConnection => 'Pas de connexion. Vérifiez votre réseau.';

  @override
  String get noConnectionTitle => 'Pas de connexion';

  @override
  String get noConnectionSubtitle =>
      'Vérifiez que votre Wi‑Fi ou vos données mobiles sont activés, puis réessayez.';

  @override
  String get noConnectionRetry => 'Réessayer';

  @override
  String get connectionErrorToast => 'Erreur de connexion Internet';

  @override
  String get errorTimeout => 'La connexion a expiré. Réessayez.';

  @override
  String get errorGeneric => 'Une erreur est survenue. Réessayez.';

  @override
  String get noProducts => 'Aucun produit';

  @override
  String get profile => 'Profil';

  @override
  String get notSignedIn => 'Non connecté';

  @override
  String get edit => 'Modifier';

  @override
  String get statistics => 'Statistiques';

  @override
  String get moreDetails => 'Plus de détails';

  @override
  String get totalShipping => 'Commandes';

  @override
  String get rating => 'Note';

  @override
  String get point => 'Points';

  @override
  String get review => 'Avis';

  @override
  String get privacySecurity => 'Confidentialité et sécurité';

  @override
  String get privacySecuritySubtitle =>
      'Gérez votre mot de passe, vos données et vos préférences de confidentialité.';

  @override
  String get privacySecuritySectionAccount => 'Compte';

  @override
  String get privacySecurityChangePassword => 'Changer le mot de passe';

  @override
  String get privacySecurityChangePasswordDesc =>
      'Mettez à jour régulièrement votre mot de passe pour plus de sécurité';

  @override
  String get privacySecurityNewPassword => 'Nouveau mot de passe';

  @override
  String get privacySecurityPasswordUpdated => 'Mot de passe mis à jour';

  @override
  String get privacySecuritySectionData => 'Données et confidentialité';

  @override
  String get privacySecurityPolicyDesc =>
      'Consultez comment nous collectons et utilisons vos données';

  @override
  String get privacySecuritySectionDanger => 'Zone de danger';

  @override
  String get privacySecurityDeleteAccount => 'Supprimer le compte';

  @override
  String get privacySecurityDeleteAccountDesc =>
      'Supprimer définitivement votre compte et toutes vos données';

  @override
  String get privacySecurityDeleteAccountConfirm =>
      'Cette action est irréversible. Toutes vos données seront définitivement supprimées. Souhaitez-vous vraiment continuer ?';

  @override
  String get privacySecurityDeleteAccountContact =>
      'Pour supprimer votre compte, contactez support@solma.com';

  @override
  String get notificationPreference => 'Préférences de notification';

  @override
  String get faq => 'FAQ';

  @override
  String get helpCenter => 'Centre d\'aide';

  @override
  String get language => 'Langue';

  @override
  String get selectLanguage => 'Choisir la langue';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get locationNotSet => 'Non renseigné';

  @override
  String get orderHistory => 'Historique des commandes';

  @override
  String get wishlist => 'Favoris';

  @override
  String get addresses => 'Adresses';

  @override
  String get paymentMethods => 'Moyens de paiement';

  @override
  String get notifications => 'Notifications';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get signOut => 'Déconnexion';

  @override
  String get settings => 'Paramètres';

  @override
  String get myCart => 'Mon panier';

  @override
  String get clear => 'Vider';

  @override
  String get promoCode => 'Code promo';

  @override
  String get apply => 'Appliquer';

  @override
  String get promoCodeApplied => 'Code appliqué';

  @override
  String get invalidPromoCode => 'Code invalide';

  @override
  String get total => 'Total';

  @override
  String get proceedToCheckout => 'Passer la commande';

  @override
  String get checkout => 'Paiement';

  @override
  String get shippingAddress => 'Adresse de livraison';

  @override
  String get payment => 'Paiement';

  @override
  String get change => 'Modifier';

  @override
  String get subtotal => 'Sous-total';

  @override
  String get shipping => 'Livraison';

  @override
  String get tax => 'TVA';

  @override
  String get paySecurely => 'Payer en toute sécurité';

  @override
  String get orderRecapSubtitle => 'Récapitulatif de la commande';

  @override
  String get productNotFound => 'Produit introuvable';

  @override
  String get sportShoes => 'Chaussures de sport';

  @override
  String get selectSize => 'Choisir la pointure';

  @override
  String get pleaseSelectSize => 'Veuillez sélectionner une pointure';

  @override
  String get pleaseSelectColour => 'Veuillez sélectionner une couleur';

  @override
  String get description => 'Description';

  @override
  String get productInformation => 'Information';

  @override
  String get colour => 'Couleur';

  @override
  String get quantityLabel => 'Quantité :';

  @override
  String get priceLabel => 'Prix';

  @override
  String get readMore => 'Lire la suite';

  @override
  String get showLess => 'Voir moins';

  @override
  String get descriptions => 'Descriptions';

  @override
  String get specifications => 'Spécifications';

  @override
  String get colors => 'Couleurs';

  @override
  String get stock => 'Stock';

  @override
  String get learnMore => 'En savoir plus';

  @override
  String get addToCart => 'Ajouter au panier';

  @override
  String get buyNow => 'Acheter maintenant';

  @override
  String get specialOffers => 'Offres spéciales';

  @override
  String sizeLabel(String value) {
    return 'Pointure $value';
  }

  @override
  String get onboardingTitle1 =>
      'Voyage dans le temps avec des chaussures premium';

  @override
  String get onboardingSubtitle1 =>
      'Chaque choix malin mettra en valeur votre style partout.';

  @override
  String get onboardingTitle2 => 'Trouvez la pointure idéale';

  @override
  String get onboardingSubtitle2 =>
      'Parcourez les collections Homme, Femme et Enfant en toute simplicité.';

  @override
  String get onboardingTitle3 => 'Paiement sécurisé et livraison rapide';

  @override
  String get onboardingSubtitle3 =>
      'Payez en toute sécurité avec Stripe et recevez votre commande rapidement.';

  @override
  String get getStarted => 'Commencer';

  @override
  String get next => 'Suivant';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get orderHistoryTitle => 'Historique des commandes';

  @override
  String get noOrders => 'Aucune commande';

  @override
  String get noOrdersSubtitle => 'Vos commandes passées apparaîtront ici';

  @override
  String get delivered => 'Livré';

  @override
  String orderNumber(String number) {
    return 'Commande n°$number';
  }

  @override
  String itemsCount(int count) {
    return '$count article(s)';
  }

  @override
  String pageNotFound(String uri) {
    return 'Page non trouvée : $uri';
  }

  @override
  String get appearance => 'Apparence';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get about => 'À propos';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get comingSoon => 'Bientôt disponible';

  @override
  String get noAddresses => 'Aucune adresse enregistrée';

  @override
  String get addAddress => 'Ajouter une adresse';

  @override
  String get noPaymentMethods => 'Aucun moyen de paiement';

  @override
  String get addCard => 'Ajouter une carte';

  @override
  String get paymentOnDelivery => 'Paiement à la livraison';

  @override
  String get paymentOnDeliveryDescription =>
      'Payez en espèces ou par carte lors de la réception de votre colis.';

  @override
  String get paymentMobileMoney => 'Mobile Money';

  @override
  String get paymentMobileMoneyDescription =>
      'Orange Money, MTN Money, Wave… Payez depuis votre portefeuille mobile.';

  @override
  String get paymentByCard => 'Carte bancaire';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get pushNotifications => 'Notifications push';

  @override
  String get ordersAndReminders => 'Commandes et rappels';

  @override
  String get offersAndPromos => 'Offres et promos';

  @override
  String get discountsAndNew => 'Réductions et publicités';

  @override
  String get orderPlacedSuccess => 'Commande enregistrée avec succès';

  @override
  String get addressLabel => 'Libellé (ex. Maison, Bureau)';

  @override
  String get fullNameRequired => 'Nom requis';

  @override
  String get addressLine1 => 'Adresse ligne 1';

  @override
  String get addressLine1Required => 'Adresse requise';

  @override
  String get addressLine2 => 'Adresse ligne 2 (optionnel)';

  @override
  String get city => 'Ville';

  @override
  String get cityRequired => 'Ville requise';

  @override
  String get region => 'Région';

  @override
  String get regionOptional => 'Région (pour les frais de livraison)';

  @override
  String get postalCode => 'Code postal';

  @override
  String get country => 'Pays';

  @override
  String get countryRequired => 'Pays requis';

  @override
  String get phone => 'Téléphone';

  @override
  String get setAsDefault => 'Définir par défaut';

  @override
  String get saveAddress => 'Enregistrer';

  @override
  String get editAddress => 'Modifier l\'adresse';

  @override
  String get deleteAddress => 'Supprimer';

  @override
  String get deleteAddressConfirm => 'Supprimer cette adresse ?';

  @override
  String get cancel => 'Annuler';

  @override
  String get addressSaved => 'Adresse enregistrée';

  @override
  String get addressDeleted => 'Adresse supprimée';

  @override
  String get markAllAsRead => 'Tout marquer comme lu';

  @override
  String get notificationsToday => 'Aujourd\'hui';

  @override
  String get notificationsYesterday => 'Hier';

  @override
  String get notificationsThisWeek => 'Cette semaine';

  @override
  String get notificationsOlder => 'Plus ancien';

  @override
  String get noNotifications => 'Aucune notification';

  @override
  String get noNotificationsSubtitle =>
      'Vous serez notifié des commandes, promos et actualités ici.';

  @override
  String get signInToSeeNotifications =>
      'Connectez-vous pour voir vos notifications.';

  @override
  String get notificationsTabAll => 'Toutes';

  @override
  String get notificationsTabOrders => 'Commandes';

  @override
  String get notificationsTabPromo => 'Publicité';

  @override
  String get notificationsTabSystem => 'Système';

  @override
  String get noNotificationsFilterSubtitle =>
      'Essayez de modifier vos critères de recherche';

  @override
  String get close => 'Fermer';

  @override
  String get bannerNewCollection => 'Nouvelle collection';

  @override
  String get bannerNewCollectionSub => 'Printemps 2026';

  @override
  String get bannerExplore => 'Explorer';

  @override
  String get bannerFreeShipping => 'Livraison gratuite';

  @override
  String get bannerFreeShippingSub => 'Sur toutes les commandes';

  @override
  String get bannerOver => 'Dès ';

  @override
  String get bannerOrderNow => 'Commander';

  @override
  String get bannerExclusive => 'Exclusivité';

  @override
  String get bannerExclusiveSub => 'Édition limitée';

  @override
  String get bannerOnlyOn => 'Uniquement sur ';

  @override
  String get bannerDiscover => 'Découvrir';

  @override
  String get wishlistEmptySubtitle =>
      'Ajoutez des favoris depuis les fiches produit.';

  @override
  String get removeFromWishlist => 'Retirer des favoris';

  @override
  String get addAllToCart => 'Tout ajouter au panier';

  @override
  String get editProfileTitle => 'Modifier le profil';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get phoneNumberHint => '06 12 34 56 78';

  @override
  String get emailAddress => 'Adresse e-mail';

  @override
  String get dateOfBirth => 'Date de naissance';

  @override
  String get dateOfBirthHint => 'JJ/MM/AAAA';

  @override
  String get addressAndLocation => 'Adresse et emplacement';

  @override
  String get addLocation => 'Ajouter un lieu';

  @override
  String get save => 'Enregistrer';

  @override
  String get profileUpdated => 'Profil mis à jour';

  @override
  String get cardholderName => 'Nom du titulaire';

  @override
  String get cardholderNameHint => 'Jean Dupont';

  @override
  String get cardholderNameRequired => 'Nom du titulaire requis';

  @override
  String get cardNumber => 'Numéro de carte';

  @override
  String get cardNumberHint => '1234 5678 9012 3456';

  @override
  String get cardNumberRequired => 'Numéro de carte requis';

  @override
  String get cardNumberInvalid => 'Numéro de carte invalide';

  @override
  String get expiryDate => 'Date d\'expiration';

  @override
  String get expiryDateHint => 'MM/AA';

  @override
  String get expiryDateRequired => 'Date d\'expiration requise';

  @override
  String get expiryDateInvalid => 'Date d\'expiration invalide';

  @override
  String get cvv => 'CVV';

  @override
  String get cvvHint => '123';

  @override
  String get cvvRequired => 'CVV requis';

  @override
  String get cvvInvalid => 'CVV invalide';

  @override
  String get cardSaved => 'Carte enregistrée';

  @override
  String get orderDetailTitle => 'Détails de la commande';

  @override
  String get orderStatusPending => 'En attente';

  @override
  String get orderStatusPaid => 'Payé';

  @override
  String get orderStatusShipped => 'Expédié';

  @override
  String get orderStatusDelivered => 'Livré';

  @override
  String get orderStatusCancelled => 'Annulé';

  @override
  String get orderReceiptThankYou => 'Merci pour votre commande';

  @override
  String get checkoutRecapFooter =>
      'Payer dans l\'app ou commander via WhatsApp.';

  @override
  String get orderViaWhatsApp => 'Commander via WhatsApp';

  @override
  String get orderReceiptSeeDetails => 'Voir les détails';

  @override
  String get shippingAddressLabel => 'Adresse de livraison';

  @override
  String get orderItems => 'Articles';

  @override
  String quantity(int count) {
    return 'Qté : $count';
  }

  @override
  String size(String value) {
    return 'Taille : $value';
  }

  @override
  String get noShippingAddress => 'Pas d\'adresse de livraison';

  @override
  String get deleteCard => 'Supprimer la carte';

  @override
  String get deleteCardConfirm => 'Supprimer cette carte ?';

  @override
  String get connectionCancelled => 'Connexion annulée';

  @override
  String get orContinueWith => 'ou continuer avec';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get continueWithApple => 'Continuer avec Apple';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get resetPasswordSent => 'E-mail de réinitialisation envoyé';

  @override
  String get termsPrefix => 'En continuant, vous acceptez nos ';

  @override
  String get termsOfService => 'Conditions d\'utilisation';

  @override
  String get andText => ' et ';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get faqSubtitle =>
      'Trouvez rapidement des réponses aux questions les plus fréquentes.';

  @override
  String get faqQ1 => 'Comment suivre ma commande ?';

  @override
  String get faqA1 =>
      'Une fois votre commande expédiée, vous recevrez un e-mail avec un lien de suivi. Vous pouvez aussi consulter l\'historique des commandes dans votre profil.';

  @override
  String get faqQ2 => 'Quels sont les délais de livraison ?';

  @override
  String get faqA2 =>
      'La livraison standard prend 3 à 5 jours ouvrés. La livraison express (si disponible) est livrée sous 24 à 48 h.';

  @override
  String get faqQ3 => 'Comment effectuer un retour ?';

  @override
  String get faqA3 =>
      'Les articles peuvent être retournés sous 14 jours dans leur état d\'origine. Contactez notre support pour obtenir une étiquette de retour.';

  @override
  String get faqQ4 => 'Quels moyens de paiement acceptez-vous ?';

  @override
  String get faqA4 =>
      'Nous acceptons les cartes bancaires (Visa, Mastercard), le paiement à la livraison et Mobile Money selon les disponibilités.';

  @override
  String get faqQ5 => 'Comment modifier mon adresse de livraison ?';

  @override
  String get faqA5 =>
      'Rendez-vous dans Profil > Adresses pour ajouter ou modifier vos adresses. Vous pouvez choisir l\'adresse au moment du paiement.';

  @override
  String get helpCenterSubtitle =>
      'Nous sommes là pour vous aider. Choisissez une option ci-dessous.';

  @override
  String get helpCenterSearchHint => 'Rechercher une réponse…';

  @override
  String get helpCenterFaqDesc =>
      'Consultez les réponses aux questions fréquentes';

  @override
  String get helpCenterContactTitle => 'Contacter le support';

  @override
  String get helpCenterCallTitle => 'Nous appeler';

  @override
  String get helpCenterCallDesc => 'Parler à notre équipe support';

  @override
  String get helpCenterWhatsAppTitle => 'WhatsApp';

  @override
  String get helpCenterWhatsAppDesc => 'Discutez avec nous sur WhatsApp';

  @override
  String get helpCenterChatTitle => 'Assistant chat';

  @override
  String get helpCenterChatDesc => 'Assistant virtuel 24/7 pour vos questions';

  @override
  String get chatWelcome =>
      'Bonjour ! Je suis l\'assistant SOLMA. Posez-moi vos questions sur la livraison, les retours, les paiements ou votre compte. Comment puis-je vous aider ?';

  @override
  String get chatFallback =>
      'Je n\'ai pas bien compris. Essayez de demander sur les délais de livraison, les retours, les moyens de paiement ou comment modifier votre adresse. Vous pouvez aussi nous appeler ou nous contacter sur WhatsApp !';

  @override
  String get chatPlaceholder => 'Tapez votre question…';

  @override
  String get chatSend => 'Envoyer';

  @override
  String get helpCenterHoursTitle => 'Horaires du support';

  @override
  String get helpCenterHours =>
      'Support disponible 24h/24, 7j/7. Nous sommes là pour vous à tout moment.';

  @override
  String get privacyPolicyLastUpdate => 'Dernière mise à jour : mars 2026';

  @override
  String get privacyIntro =>
      'SOLMA s\'engage à protéger votre vie privée. Cette politique décrit comment nous collectons, utilisons et protégeons vos données personnelles.';

  @override
  String get privacySection1Title => '1. Données que nous collectons';

  @override
  String get privacySection1Content =>
      'Nous collectons les données que vous nous fournissez directement : identifiant et mot de passe, nom, adresse e-mail, numéro de téléphone, date de naissance (optionnel), photo de profil (optionnel) ; adresses de livraison (nom, adresse postale, ville, code postal, pays, téléphone) ; données de commande (articles, montants, statut). Si vous utilisez la connexion Google ou Apple, nous recevons votre nom et e-mail associés. Pour les notifications push, nous enregistrons un identifiant technique (token FCM). L\'application stocke localement vos préférences (thème, langue, devise) sur votre appareil.';

  @override
  String get privacySection2Title => '2. Finalités du traitement';

  @override
  String get privacySection2Content =>
      'Vos données sont utilisées pour : créer et gérer votre compte ; traiter vos commandes et paiements ; gérer vos adresses de livraison ; vous envoyer des notifications (confirmation de commande, livraison, promotions si vous y avez consenti) ; personnaliser l\'application (devise, langue) ; assurer la sécurité et prévenir les fraudes. Nous ne vendons jamais vos données à des tiers.';

  @override
  String get privacySection3Title => '3. Sous-traitants et partenaires';

  @override
  String get privacySection3Content =>
      'Nous nous appuyons sur des prestataires techniques de confiance : Supabase (hébergement, base de données, authentification) ; Stripe (paiements sécurisés, norme PCI-DSS) ; Firebase / Google (notifications push) ; Google et Apple (connexion sociale, si vous l\'utilisez) ; Exchange Rate API (taux de change pour l\'affichage des prix). Ces prestataires traitent vos données conformément à nos instructions et aux exigences légales.';

  @override
  String get privacySection4Title => '4. Durée de conservation';

  @override
  String get privacySection4Content =>
      'Les données de compte et de profil sont conservées tant que votre compte est actif. Les données de commande sont conservées pour les obligations légales et comptables (généralement 5 à 10 ans selon la réglementation). Les tokens de notification sont supprimés à la déconnexion. Vous pouvez demander la suppression de votre compte à tout moment.';

  @override
  String get privacySection5Title => '5. Vos droits (RGPD)';

  @override
  String get privacySection5Content =>
      'Conformément au Règlement général sur la protection des données (RGPD), vous disposez des droits suivants : accès à vos données ; rectification des données inexactes ; suppression (« droit à l\'oubli ») ; limitation du traitement ; portabilité des données ; opposition au traitement ; retirer votre consentement. Pour exercer ces droits, contactez-nous à support@solma.com. Vous pouvez également introduire une réclamation auprès de l\'autorité de contrôle de votre pays.';

  @override
  String get privacySection6Title => '6. Sécurité';

  @override
  String get privacySection6Content =>
      'Nous mettons en œuvre des mesures techniques et organisationnelles appropriées : chiffrement HTTPS pour toutes les communications ; authentification sécurisée ; paiements délégués à Stripe (PCI-DSS) ; stockage des données sensibles sur des infrastructures sécurisées. Aucun numéro de carte bancaire n\'est stocké sur nos serveurs.';

  @override
  String get privacySection7Title => '7. Stockage local et préférences';

  @override
  String get privacySection7Content =>
      'L\'application utilise le stockage local de votre appareil pour vos préférences (thème clair/sombre, langue, devise), votre panier et vos favoris. Ces données restent sur votre appareil et ne sont pas transmises à des tiers, sauf pour la synchronisation de votre compte si vous êtes connecté. Les taux de change sont mis en cache localement pour améliorer les performances.';

  @override
  String get privacySection8Title => '8. Modifications et contact';

  @override
  String get privacySection8Content =>
      'Nous pouvons mettre à jour cette politique pour refléter des changements de nos pratiques ou de la réglementation. La date de dernière mise à jour est indiquée en tête de document. Pour toute question relative à vos données personnelles, contactez-nous : support@solma.com ou via le Centre d\'aide de l\'application.';

  @override
  String get sessionExpired => 'Session expirée';

  @override
  String get sessionExpiredMessage =>
      'Votre session a expiré. Veuillez vous reconnecter.';

  @override
  String get reconnect => 'Se reconnecter';

  @override
  String get reviews => 'Avis';

  @override
  String reviewsCount(int count) {
    return '$count avis';
  }

  @override
  String get noReviews => 'Aucun avis pour le moment';

  @override
  String get beFirstToReview =>
      'Soyez le premier à donner votre avis sur ce produit';

  @override
  String get writeReview => 'Donner mon avis';

  @override
  String get editReview => 'Modifier mon avis';

  @override
  String get yourRating => 'Votre note';

  @override
  String get yourComment => 'Votre commentaire (optionnel)';

  @override
  String get submitReview => 'Publier';

  @override
  String get reviewSubmitted => 'Avis publié';

  @override
  String get reviewUpdated => 'Avis modifié';

  @override
  String get reviewDeleted => 'Avis supprimé';

  @override
  String get deleteReview => 'Supprimer l\'avis';

  @override
  String get deleteReviewConfirm => 'Supprimer cet avis ?';

  @override
  String get loginToReview => 'Connectez-vous pour laisser un avis';

  @override
  String get verifiedPurchase => 'Achat vérifié';

  @override
  String get helpful => 'Utile';

  @override
  String get notHelpful => 'Pas utile';

  @override
  String peopleFoundHelpful(int count) {
    return '$count personne(s) ont trouvé cet avis utile';
  }

  @override
  String get sortBy => 'Trier par';

  @override
  String get sortRecent => 'Plus récents';

  @override
  String get sortHighest => 'Mieux notés';

  @override
  String get sortLowest => 'Moins bien notés';

  @override
  String get sortHelpful => 'Plus utiles';

  @override
  String get seeAllReviews => 'Voir tous les avis';

  @override
  String seeMoreReviews(int count) {
    return 'Voir plus ($count restant)';
  }

  @override
  String get reviewTitle => 'Titre de l\'avis';

  @override
  String get reviewTitleHint => 'Résumez votre expérience en quelques mots';

  @override
  String get pros => 'Points positifs';

  @override
  String get prosHint => 'Ce que vous avez aimé...';

  @override
  String get cons => 'Points à améliorer';

  @override
  String get consHint => 'Ce qui pourrait être mieux...';

  @override
  String get starExcellent => 'Excellent';

  @override
  String get starGood => 'Bien';

  @override
  String get starAverage => 'Correct';

  @override
  String get starPoor => 'Médiocre';

  @override
  String get starBad => 'Mauvais';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get yesterday => 'Hier';

  @override
  String get daysAgo => 'jours';

  @override
  String get promoCodePlaceholder => 'Entrez un code promo';

  @override
  String promoApplied(String amount) {
    return 'Code promo appliqué : -$amount';
  }

  @override
  String get promoMinOrder => 'Commande minimum non atteinte';

  @override
  String get promoExpired => 'Ce code promo a expiré';

  @override
  String get promoMaxUsed => 'Ce code promo n\'est plus disponible';

  @override
  String get promoNotFound => 'Code promo introuvable';

  @override
  String get discountLabel => 'Réduction';

  @override
  String get removePromo => 'Retirer';

  @override
  String get orderTracking => 'Suivi de commande';

  @override
  String get trackingOrdered => 'Commandé';

  @override
  String get trackingConfirmed => 'Confirmé';

  @override
  String get trackingPreparing => 'En préparation';

  @override
  String get trackingShipped => 'Expédié';

  @override
  String get trackingInDelivery => 'En livraison';

  @override
  String get trackingDelivered => 'Livré';

  @override
  String get noTrackingInfo => 'Aucune information de suivi disponible';

  @override
  String get whyChooseSOLMA => 'Pourquoi choisir SOLMA ?';

  @override
  String get dataProtection => 'Protection des données';

  @override
  String get securePayment => 'Paiement sécurisé';

  @override
  String get deliveryWorldwide => 'Livraison partout au monde';

  @override
  String get searchHint => 'Nike, Jordan…';

  @override
  String get noNewArrivals => 'Aucune publicité';

  @override
  String get newArrivals => 'Publicité';

  @override
  String get currency => 'Devise';

  @override
  String get currentCurrency => 'Devise actuelle';

  @override
  String get chooseCurrency => 'Choisir une devise';

  @override
  String get currencyInfoTitle => 'Information';

  @override
  String get currencyInfoBody =>
      'La devise sélectionnée sera utilisée pour afficher tous les prix dans l\'application. Les taux de conversion seront appliqués automatiquement.';

  @override
  String get currencyInfoNote =>
      'Note : Les conversions sont basées sur les taux de change en temps réel.';

  @override
  String get currencyXof => 'Franc CFA BCEAO';

  @override
  String get currencyUsd => 'Dollar américain';

  @override
  String get currencyEur => 'Euro';

  @override
  String get imageUnavailable => 'Image indisponible';

  @override
  String get notificationChannelName => 'Notifications SOLMA';

  @override
  String get notificationChannelDesc => 'Notifications de l\'application SOLMA';

  @override
  String get orderConfirmed => 'Commande confirmée';

  @override
  String orderConfirmedBodyMultiple(String shortId, int count, String total) {
    return 'Votre commande #$shortId a été enregistrée. $count articles, total $total.';
  }

  @override
  String orderConfirmedBodySingle(String shortId, String total) {
    return 'Votre commande #$shortId a été enregistrée. Total $total.';
  }
}
