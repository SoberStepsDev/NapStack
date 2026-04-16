#!/bin/bash
# NapStack Schema Provisioning — do uruchomienia lokalnie
# Zmienne środowiskowe są ładowane z .env automatycznie przez pub

echo "🔧 Provisioning NapStack schema..."
echo ""
echo "Uwaga: Skrypt przechowuje APPWRITE_API_KEY z .env lokalnie."
echo "Nigdy nie commituj tego skryptu z kluczami do repo!"
echo ""

# Źródło .env — automatyczne ładowanie zmiennych
if [ -f .env ]; then
    export $(cat .env | xargs)
fi

# Weryfikacja wymaganych zmiennych
if [ -z "$APPWRITE_ENDPOINT" ] || [ -z "$APPWRITE_PROJECT_ID" ] || [ -z "$APPWRITE_API_KEY" ]; then
    echo "❌ Brakuje zmiennych Appwrite w .env"
    exit 1
fi

echo "✅ Zmienne Appwrite załadowane"
echo ""
echo "🚀 Uruchamianie provision_schema.dart..."
echo ""

dart run tools/provision_schema.dart

echo ""
echo "✅ Provisioning ukończony!"
echo ""
echo "Następny krok: Appwrite Function env variables"
