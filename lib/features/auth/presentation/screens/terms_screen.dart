import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key, required this.onAccept});

  final VoidCallback onAccept;

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool _accepted = false;

  static const _sectionsEs = <_TermsSection>[
    _TermsSection('01', 'Quiénes somos y qué hace Feyam', 'Feyam es una plataforma de tecnología de comercio internacional operada por FEYAM UNIVERSE LLC que facilita la gestión de compras en tiendas de terceros, recepción de paquetes, consolidación y coordinación de transporte doméstico e internacional.'),
    _TermsSection('02', 'Cómo usar la plataforma', 'La plataforma permite seleccionar o especificar un producto por link o referencia, solicitar la gestión de compra, recibir cotización, aceptar condiciones, realizar el pago y recibir seguimiento del pedido.'),
    _TermsSection('03', 'Requisitos para usar los servicios', 'Debés tener al menos 18 años o la mayoría de edad legal en tu jurisdicción, capacidad legal para contratar, brindar información veraz y usar la plataforma solo para fines lícitos.'),
    _TermsSection('04', 'Cuenta de usuario y seguridad', 'Sos responsable de mantener la confidencialidad de tu contraseña y de toda actividad realizada desde tu cuenta. Notificanos inmediatamente si detectás uso no autorizado.'),
    _TermsSection('05', 'Pedidos, solicitudes y aceptación', 'Un pedido es una solicitud de servicio y no implica aceptación automática por parte de Feyam. El pedido se considera aceptado solo cuando Feyam lo confirma expresamente.'),
    _TermsSection('06', 'Precios, cotizaciones y pagos', 'Los precios visibles pueden ser estimados y sujetos a cambios por factores ajenos a Feyam: cambios en la tienda, impuestos, cargos de pago, logística, tipo de cambio u otros costos operativos.'),
    _TermsSection('07', 'Productos y exactitud de la información', 'Feyam no garantiza la exactitud, disponibilidad, compatibilidad, autenticidad ni calidad de los productos. El usuario es responsable de revisar cuidadosamente la información del producto solicitado.'),
    _TermsSection('08', 'Restricciones de productos', 'No podés solicitar productos ilegales, restringidos por aduanas o transporte, peligrosos, perecederos sin autorización especial, o que infrinjan derechos de terceros.'),
    _TermsSection('09', 'Envíos, entrega y logística', 'Los tiempos de procesamiento, tránsito y entrega son estimados y pueden variar por disponibilidad del vendedor, transportistas, consolidación, aduanas, clima o fuerza mayor.'),
    _TermsSection('10', 'Aduanas, impuestos y regulaciones', 'Ciertos envíos pueden estar sujetos a impuestos, aranceles y cargos de aduana. Feyam no garantiza exenciones ni montos específicos.'),
    _TermsSection('11', 'Cancelaciones, devoluciones y reembolsos', 'Se rigen por la Política de Reembolsos, Cancelaciones e Incidentes de Feyam (feyam.com/refunds).'),
    _TermsSection('12', 'Conducta del usuario y usos prohibidos', 'No podés usar la plataforma para fines ilegales o fraudulentos, suplantar identidades, interferir con la operación del sistema, realizar chargebacks fraudulentos.'),
    _TermsSection('13', 'Propiedad intelectual', 'Todo el software, diseño, código, marcas, logos, textos, bases de datos y contenido propietario de la plataforma son propiedad de FEYAM UNIVERSE LLC.'),
    _TermsSection('14', 'Links y servicios de terceros', 'La plataforma puede contener links o integraciones con terceros. Feyam no controla esos terceros y no es responsable por su disponibilidad, contenido, políticas ni transacciones.'),
    _TermsSection('15', 'Exención de garantías', 'En la máxima medida permitida por la ley, los servicios se brindan "tal como están" sin garantías de ningún tipo.'),
    _TermsSection('16', 'Limitación de responsabilidad', 'La responsabilidad total de Feyam ante un reclamo relacionado con un pedido se limita al monto efectivamente pagado por el usuario a Feyam.'),
    _TermsSection('17', 'Indemnización', 'El usuario acuerda defender, indemnizar y mantener indemne a FEYAM UNIVERSE LLC de reclamos, pérdidas y gastos que surjan del mal uso de la plataforma.'),
    _TermsSection('18', 'Suspensión y terminación', 'Feyam puede suspender o cancelar tu acceso por violaciones a estos Términos, riesgo legal, fraude o necesidad de proteger la plataforma u otros usuarios.'),
    _TermsSection('19', 'Modificaciones a los Términos', 'Podemos actualizar estos Términos en cualquier momento publicando la versión actualizada. El uso continuado de la plataforma constituye aceptación de los Términos modificados.'),
    _TermsSection('20', 'Comunicaciones electrónicas', 'Aceptás recibir comunicaciones electrónicas relacionadas con tu cuenta, pedidos y actualizaciones.'),
    _TermsSection('21', 'Ley aplicable y jurisdicción', 'Estos Términos se rigen por las leyes del Estado de Florida, Estados Unidos.'),
    _TermsSection('22', 'Divisibilidad y no renuncia', 'Si alguna disposición de estos Términos resulta inválida o inaplicable, las disposiciones restantes permanecerán en plena vigencia.'),
    _TermsSection('23', 'Idioma', 'Estos Términos pueden estar disponibles en más de un idioma. Versión vigente: Español.'),
    _TermsSection('24', 'Contacto', 'FEYAM UNIVERSE LLC · 7520 NW 104th Ave, Ste A103 PMB 4377, Doral, FL, USA · soporte@feyam.com · www.feyam.com'),
  ];

  static const _sectionsEn = <_TermsSection>[
    _TermsSection('01', 'Who We Are and What Feyam Does', 'Feyam is an international commerce and logistics technology platform operated by FEYAM UNIVERSE LLC that facilitates purchase management at third-party stores, package receipt, consolidation, and transport coordination.'),
    _TermsSection('02', 'How to Use the Platform', 'The Platform allows you to select or specify a product by link or reference, request purchase management, receive a quote, accept conditions, make payment, and receive order tracking.'),
    _TermsSection('03', 'Eligibility to Use the Services', 'You must be at least 18 years old or the legal age of majority in your jurisdiction, have legal capacity to contract, provide truthful information, and use the Platform solely for lawful purposes.'),
    _TermsSection('04', 'User Account and Security', 'You are responsible for maintaining the confidentiality of your password and all activity conducted from your account. Notify us immediately if you detect unauthorized use.'),
    _TermsSection('05', 'Orders, Purchase Requests, and Acceptance', 'An order is a service request and does not imply automatic acceptance by Feyam. An order is considered accepted only when Feyam expressly confirms it.'),
    _TermsSection('06', 'Pricing, Quotes, and Payments', 'Visible prices may be estimates subject to changes beyond Feyam\'s control: store changes, taxes, payment charges, logistics, exchange rates, or other operational costs.'),
    _TermsSection('07', 'Products and Accuracy of Information', 'Feyam does not guarantee the accuracy, availability, compatibility, authenticity, or quality of products.'),
    _TermsSection('08', 'Product Restrictions and Compliance', 'You may not request products that are illegal, restricted by customs or transport, hazardous, perishable without special authorization, or that infringe third-party rights.'),
    _TermsSection('09', 'Shipping, Delivery, and Logistics', 'Processing, transit, and delivery times are estimates and may vary due to seller availability, carriers, consolidation, customs, weather, or force majeure.'),
    _TermsSection('10', 'Customs, Taxes, and Regulations', 'Certain shipments may be subject to taxes, duties, and customs charges. Feyam does not guarantee exemptions or specific amounts.'),
    _TermsSection('11', 'Cancellations, Returns, and Refunds', 'Governed by Feyam\'s Refund, Cancellation, and Incident Policy (feyam.com/refunds).'),
    _TermsSection('12', 'User Conduct and Prohibited Uses', 'You may not use the Platform for illegal or fraudulent purposes, impersonate others, interfere with Platform operations, or conduct fraudulent chargebacks.'),
    _TermsSection('13', 'Intellectual Property', 'All software, design, code, trademarks, logos, texts, databases, and proprietary content of the Platform are owned by FEYAM UNIVERSE LLC.'),
    _TermsSection('14', 'Third-Party Links and Services', 'The Platform may contain links or integrations with third parties. Feyam is not responsible for their availability, content, policies, or transactions.'),
    _TermsSection('15', 'Warranty Disclaimers', 'To the maximum extent permitted by applicable law, the Services are provided "as is" without warranties of any kind.'),
    _TermsSection('16', 'Limitation of Liability', 'Feyam\'s total liability is limited to the amount actually paid by you to Feyam for the specific service that gave rise to the claim.'),
    _TermsSection('17', 'Indemnification', 'You agree to defend, indemnify, and hold harmless FEYAM UNIVERSE LLC from claims, losses, and expenses arising from misuse of the Platform.'),
    _TermsSection('18', 'Suspension and Termination', 'Feyam may suspend or cancel your access for violations of these Terms, legal risk, fraud, or to protect the Platform or other users.'),
    _TermsSection('19', 'Modifications to the Terms', 'We may update these Terms at any time. Continued use of the Platform after changes are published constitutes acceptance of the modified Terms.'),
    _TermsSection('20', 'Electronic Communications', 'You agree to receive electronic communications related to your account, orders, and updates.'),
    _TermsSection('21', 'Governing Law and Jurisdiction', 'These Terms are governed by the laws of the State of Florida, USA.'),
    _TermsSection('22', 'Severability and Non-Waiver', 'If any provision of these Terms is found invalid or unenforceable, the remaining provisions will remain in full force.'),
    _TermsSection('23', 'Language', 'These Terms may be available in more than one language. Governing version: Spanish.'),
    _TermsSection('24', 'Contact', 'FEYAM UNIVERSE LLC · 7520 NW 104th Ave, Ste A103 PMB 4377, Doral, FL, USA · soporte@feyam.com · www.feyam.com'),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    final sections = isEs ? _sectionsEs : _sectionsEn;

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 390).clamp(0.9, 1.1);

        return Scaffold(
          backgroundColor: colors.surface,
          body: SafeArea(
            child: Column(
              children: <Widget>[
                // Header
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: colors.outlineVariant)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20 * scale, 18 * scale, 20 * scale, 14 * scale),
                    child: Row(
                      children: <Widget>[
                        Image.asset(
                          'assets/branding/logo.png',
                          height: 28 * scale,
                        ),
                        SizedBox(width: 14 * scale),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                l10n.termsTitle,
                                style: textTheme.titleMedium?.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17 * scale,
                                ),
                              ),
                              SizedBox(height: 2 * scale),
                              Text(
                                l10n.termsUpdated,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 11 * scale,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20 * scale, 14 * scale, 20 * scale, 8 * scale),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          l10n.termsIntro,
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 13 * scale,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 20 * scale),
                        for (final s in sections) ...[
                          _SectionItem(scale: scale, section: s),
                          SizedBox(height: 18 * scale),
                        ],
                        Divider(color: colors.outlineVariant),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8 * scale),
                          child: Text(
                            '© 2026 FEYAM UNIVERSE LLC',
                            textAlign: TextAlign.center,
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                              fontSize: 11 * scale,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Footer
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border(top: BorderSide(color: colors.outlineVariant)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16 * scale, 12 * scale, 16 * scale, 20 * scale),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () => setState(() => _accepted = !_accepted),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: EdgeInsets.all(14 * scale),
                            decoration: BoxDecoration(
                              color: _accepted ? colors.primaryContainer : colors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12 * scale),
                              border: Border.all(
                                color: _accepted ? colors.primary : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: 22 * scale,
                                  height: 22 * scale,
                                  decoration: BoxDecoration(
                                    color: _accepted ? colors.primary : Colors.transparent,
                                    borderRadius: BorderRadius.circular(5 * scale),
                                    border: _accepted ? null : Border.all(color: colors.outline, width: 2),
                                  ),
                                  child: _accepted
                                      ? Icon(Icons.check_rounded, size: 16 * scale, color: colors.onPrimary)
                                      : null,
                                ),
                                SizedBox(width: 12 * scale),
                                Expanded(
                                  child: Text(
                                    l10n.termsAccept,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: _accepted ? colors.onPrimaryContainer : colors.onSurface,
                                      fontSize: 13 * scale,
                                      height: 1.45,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 12 * scale),
                        SizedBox(
                          height: 52 * scale,
                          child: FilledButton(
                            onPressed: _accepted ? widget.onAccept : null,
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12 * scale),
                              ),
                              textStyle: textTheme.labelLarge?.copyWith(
                                fontSize: 16 * scale,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            child: Text(l10n.termsContinue),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionItem extends StatelessWidget {
  const _SectionItem({required this.scale, required this.section});

  final double scale;
  final _TermsSection section;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(4 * scale),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 7 * scale, vertical: 3 * scale),
                child: Text(
                  section.num,
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontSize: 10 * scale,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10 * scale),
            Expanded(
              child: Text(
                section.title,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 13 * scale,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5 * scale),
        Padding(
          padding: EdgeInsets.only(left: 4 * scale),
          child: Text(
            section.body,
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 12 * scale,
              height: 1.55,
            ),
          ),
        ),
      ],
    );
  }
}

class _TermsSection {
  const _TermsSection(this.num, this.title, this.body);

  final String num;
  final String title;
  final String body;
}
