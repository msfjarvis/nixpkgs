{
  lib,
  azure-core,
  buildPythonPackage,
  fetchPypi,
  isodate,
  pythonOlder,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "azure-keyvault-administration";
  version = "4.6.0";
  pyproject = true;

  disabled = pythonOlder "3.9";

  src = fetchPypi {
    pname = "azure_keyvault_administration";
    inherit version;
    hash = "sha256-1YMCni76oJ4eHEb3wBuxvB+JA4isvyNUpC0fM3n3NOQ=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    azure-core
    typing-extensions
    isodate
  ];

  # Tests require checkout from mono-repo
  doCheck = false;

  pythonNamespaces = [ "azure.keyvault" ];

  pythonImportsCheck = [ "azure.keyvault.administration" ];

  meta = with lib; {
    description = "Microsoft Azure Key Vault Administration Client Library for Python";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/master/sdk/keyvault/azure-keyvault-administration";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-keyvault-administration_${version}/sdk/keyvault/azure-keyvault-administration/CHANGELOG.md";
    license = licenses.mit;
    maintainers = [ ];
  };
}
