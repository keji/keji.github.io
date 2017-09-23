android.net.SSLCertificateSocketFactory.java

    private SSLSocketFactory makeSocketFactory(
            KeyManager[] keyManagers, TrustManager[] trustManagers) {
        try {
            OpenSSLContextImpl sslContext = OpenSSLContextImpl.getPreferred();
            sslContext.engineInit(keyManagers, trustManagers, null);
            sslContext.engineGetClientSessionContext().setPersistentCache(mSessionCache);
            return sslContext.engineGetSocketFactory();
        } catch (KeyManagementException e) {
            Log.wtf(TAG, e);
            return (SSLSocketFactory) SSLSocketFactory.getDefault();  // Fallback
        }
    }

    @Override
    public Socket createSocket(String host, int port) throws IOException {
        OpenSSLSocketImpl s = (OpenSSLSocketImpl) getDelegate().createSocket(host, port);
        s.setNpnProtocols(mNpnProtocols);
        s.setAlpnProtocols(mAlpnProtocols);
        s.setHandshakeTimeout(mHandshakeTimeoutMillis);
        s.setChannelIdPrivateKey(mChannelIdPrivateKey);
        if (mSecure) {
            verifyHostname(s, host);
        }
        return s;
    }

    public static void verifyHostname(Socket socket, String hostname) throws IOException {
        if (!(socket instanceof SSLSocket)) {
            throw new IllegalArgumentException("Attempt to verify non-SSL socket");
        }

        if (!isSslCheckRelaxed()) {
            // The code at the start of OpenSSLSocketImpl.startHandshake()
            // ensures that the call is idempotent, so we can safely call it.
            SSLSocket ssl = (SSLSocket) socket;
            ssl.startHandshake();

            SSLSession session = ssl.getSession();
            if (session == null) {
                throw new SSLException("Cannot verify SSL socket without session");
            }
            if (!HttpsURLConnection.getDefaultHostnameVerifier().verify(hostname, session)) {
                throw new SSLPeerUnverifiedException("Cannot verify hostname: " + hostname);
            }
        }
    }

com.squareup.okhttp.internal.tls.OkHostnameVerifier.java

    @Override
    public boolean verify(String host, SSLSession session) {
      try {
        Certificate[] certificates = session.getPeerCertificates(); //检验服务器端的证书
        return verify(host, (X509Certificate) certificates[0]);
      } catch (SSLException e) {
        return false;
      }
    }

 ## 如何注册自定义的SSLSocketFactory
 ``` java
SchemeRegistry registry = new SchemeRegistry();
registry.register(new Scheme("https",new MyCustomSocketFactory(),443));
DefaultHttpClient DefaultHttpClient
    = new DefaultHttpClient(new ThreadSafeClientConnManager(httpParameters,registry),httpParameters);


```
### 如何来从而是TLS_FALLBACK_SVSC
``` java
//来自源码 libcore.javax.net.ssl.SSLSocketTest
public void test_SSLSocket_sendsTlsFallbackScsv_Fallback_Success() throws Exception {
    TestSSLContext context = TestSSLContext.create();

    final SSLSocket client = (SSLSocket)
        context.clientContext.getSocketFactory().createSocket(context.host, context.port);
    final SSLSocket server = (SSLSocket) context.serverSocket.accept();

    final String[] serverCipherSuites = server.getEnabledCipherSuites();
    final String[] clientCipherSuites = new String[serverCipherSuites.length + 1];
    System.arraycopy(serverCipherSuites, 0, clientCipherSuites, 0, serverCipherSuites.length);
    clientCipherSuites[serverCipherSuites.length] = StandardNames.CIPHER_SUITE_FALLBACK;

    ExecutorService executor = Executors.newFixedThreadPool(2);
    Future<Void> s = executor.submit(new Callable<Void>() {
            public Void call() throws Exception {
                server.setEnabledProtocols(new String[] { "TLSv1.2" });
                server.setEnabledCipherSuites(serverCipherSuites);
                server.startHandshake();
                return null;
            }
        });
    Future<Void> c = executor.submit(new Callable<Void>() {
            public Void call() throws Exception {
                client.setEnabledProtocols(new String[] { "TLSv1.2" });
                client.setEnabledCipherSuites(clientCipherSuites);
                client.startHandshake();
                return null;
            }
        });
    executor.shutdown();

    s.get();
    c.get();
    client.close();
    server.close();
    context.close();
}
```

TLS 1.0 <br>
IETF将SSL标准化,即 RFC 2246,并将其称为TLS(Transport Layer Security). 从技术上讲,TLS 1.0与SSL3.0的差异非常微小.但正如RFC所述"the differences between this protocol and SSL 3.0 are not dramatic,but they are significant enough to preclude interoperability between TLS1.0 and SSL 3.0"(本协议与SSL3.0的差异非常微小,却足以排除TLS1.0和SSL 3.0之间的互操作性).TLS1.0 包括可以降级到SSL3.0的实现,这削弱了连接的安全性

SSLContext context = SSLContext.getInstance("TLS");
